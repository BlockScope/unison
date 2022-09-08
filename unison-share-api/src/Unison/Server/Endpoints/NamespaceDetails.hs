{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeOperators #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Unison.Server.Endpoints.NamespaceDetails where

import Control.Monad.Except
import Data.Aeson
import Data.OpenApi (ToSchema)
import qualified Data.Text as Text
import Servant (Capture, QueryParam, (:>))
import Servant.Docs (DocCapture (..), ToCapture (..), ToSample (..))
import Servant.OpenApi ()
import qualified U.Codebase.Causal as V2Causal
import Unison.Codebase (Codebase)
import qualified Unison.Codebase as Codebase
import qualified Unison.Codebase.Branch as V1Branch
import qualified Unison.Codebase.Path as Path
import Unison.Codebase.Path.Parse (parsePath')
import qualified Unison.Codebase.Runtime as Rt
import Unison.Codebase.ShortBranchHash (ShortBranchHash)
import qualified Unison.Codebase.SqliteCodebase.Conversions as Cv
import Unison.Parser.Ann (Ann)
import Unison.Prelude
import Unison.Server.Backend
import qualified Unison.Server.Backend as Backend
import Unison.Server.Doc (Doc)
import Unison.Server.Types
  ( APIGet,
    NamespaceFQN,
    UnisonHash,
    UnisonName,
    mayDefaultWidth,
    v2CausalBranchToUnisonHash,
  )
import Unison.Symbol (Symbol)
import Unison.Util.Pretty (Width)

type NamespaceDetailsAPI =
  "namespaces" :> Capture "namespace" NamespaceFQN
    :> QueryParam "rootBranch" ShortBranchHash
    :> QueryParam "renderWidth" Width
    :> APIGet NamespaceDetails

instance ToCapture (Capture "namespace" Text) where
  toCapture _ =
    DocCapture
      "namespace"
      "The fully qualified name of a namespace. The leading `.` is optional."

instance ToSample NamespaceDetails where
  toSamples _ =
    [ ( "When no value is provided for `namespace`, the root namespace `.` is "
          <> "listed by default",
        NamespaceDetails
          "."
          "#gjlk0dna8dongct6lsd19d1o9hi5n642t8jttga5e81e91fviqjdffem0tlddj7ahodjo5"
          Nothing
      )
    ]

data NamespaceDetails = NamespaceDetails
  { fqn :: UnisonName,
    hash :: UnisonHash,
    readme :: Maybe Doc
  }
  deriving (Generic, Show)

instance ToJSON NamespaceDetails where
  toEncoding = genericToEncoding defaultOptions

deriving instance ToSchema NamespaceDetails

namespaceDetails ::
  Rt.Runtime Symbol ->
  Codebase IO Symbol Ann ->
  NamespaceFQN ->
  Maybe ShortBranchHash ->
  Maybe Width ->
  Backend IO NamespaceDetails
namespaceDetails runtime codebase namespaceName maySBH mayWidth =
  let errFromEither f = either (throwError . f) pure

      fqnToPath fqn = do
        let fqnS = Text.unpack fqn
        path' <- errFromEither (`Backend.BadNamespace` fqnS) $ parsePath' fqnS
        pure (Path.fromPath' path')

      width = mayDefaultWidth mayWidth
   in do
        namespacePath <- fqnToPath namespaceName
        rootCausal <- Backend.resolveRootBranchHashV2 codebase maySBH
        namespaceCausal <- fromMaybe (Cv.causalbranch1to2 (V1Branch.empty)) <$> (lift $ Codebase.getShallowCausalAtPath codebase namespacePath (Just rootCausal))
        shallowBranch <- lift $ V2Causal.value namespaceCausal
        namespaceDetails <- do
          (_localNamesOnly, ppe) <- Backend.scopedNamesForBranchHash codebase (Just rootCausal) namespacePath
          readme <-
            Backend.findShallowReadmeInBranchAndRender
              width
              runtime
              codebase
              ppe
              shallowBranch
          let causalHash = v2CausalBranchToUnisonHash namespaceCausal
          pure $ NamespaceDetails namespaceName causalHash readme

        pure $ namespaceDetails
