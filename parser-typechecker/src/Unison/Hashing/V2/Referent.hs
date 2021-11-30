{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PatternSynonyms #-}

module Unison.Hashing.V2.Referent
  ( Referent,
    pattern Ref,
    pattern Con,
    ConstructorId,
  )
where

import Unison.DataDeclaration.ConstructorId (ConstructorId)
import Unison.Hashing.V2.BuildHashable (Hashable)
import qualified Unison.Hashing.V2.BuildHashable as H
import Unison.Hashing.V2.Reference (Reference)

data Referent = Ref Reference | Con Reference ConstructorId
  deriving (Show, Ord, Eq)

instance Hashable Referent where
  tokens (Ref r) = [H.Tag 0] ++ H.tokens r
  tokens (Con r i) = [H.Tag 2] ++ H.tokens r ++ H.tokens i
