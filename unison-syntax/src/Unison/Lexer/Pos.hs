{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE DeriveFoldable #-}
{-# LANGUAGE DeriveTraversable #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ViewPatterns #-}

{-# OPTIONS_GHC -Wno-name-shadowing #-}

module Unison.Lexer.Pos (Pos (..), Line, Column, line, column) where

type Line = Int

type Column = Int

data Pos = Pos {-# UNPACK #-} !Line {-# UNPACK #-} !Column deriving (Eq, Ord)

line :: Pos -> Line
line (Pos line _) = line

column :: Pos -> Column
column (Pos _ column) = column

instance Show Pos where show (Pos line col) = "line " <> show line <> ", column " <> show col

instance Semigroup Pos where
  Pos line col <> Pos line2 col2 =
    if line2 == 0
      then Pos line (col + col2)
      else Pos (line + line2) col2

instance Monoid Pos where
  mempty = Pos 0 0
