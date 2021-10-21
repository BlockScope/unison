module Unison.Hashing.V2.TermEdit (TermEdit (..)) where

import Unison.Hashable (Hashable)
import qualified Unison.Hashable as H
import Unison.Hashing.V2.Referent (Referent)

data TermEdit = Replace Referent | Deprecate
  deriving (Eq, Ord, Show)

instance Hashable TermEdit where
  tokens (Replace r) = [H.Tag 0] ++ H.tokens r
  tokens Deprecate = [H.Tag 1]
