module Database.Postgres.ToPg
  -- ( class ToPg
  ( ToPg
  -- , toPg

  -- v Forced exports
  -- , class InnerTup
  -- , toPg_inner
  , toPg_tup0
  , toPg_Int
  , toPg_Number
  , toPg_String
  , toPg_Maybe
  , toPg_Tup
  ) where

import Prelude

import Data.Foldable (intercalate, foldr)
import Data.Maybe (Maybe(..))
import Data.Set (Set)
import Data.Set as Set
import Data.Array as Array
import Data.Tuple.Nested ((/\), type (/\))
import Data.String.Common (replaceAll) as Str
import Data.String.Pattern (Pattern(..), Replacement(..)) as Str
import Data.Newtype (un)

import Database.Postgres.Types (Tup(..), PgExpr(..))

replace :: { this :: String, with :: String } -> String -> String
replace { this, with } = Str.replaceAll (Str.Pattern this) (Str.Replacement with)

escape :: Array String -> String -> String
escape specials =
  (specials <> ["\""])
  # map (\s -> replace { this: s, with: "\\" <> s })
  # foldr compose identity

encloseWith :: String -> String -> String -> String
encloseWith before after str = before <> str <> after

-- end util --
type ToPg a = a -> PgExpr

toPg_tup0 :: ToPg (Tup Unit)
toPg_tup0 _ = PgExpr "()"

toPg_Int :: ToPg Int
toPg_Int = show >>> PgExpr

toPg_Number :: ToPg Number
toPg_Number = show >>> PgExpr

toPg_String :: ToPg String
toPg_String = PgExpr

toPg_Maybe :: ∀ a. ToPg a -> ToPg (Maybe a)
toPg_Maybe toPg = case _ of
  Nothing -> PgExpr "null"
  Just v -> toPg v

toPg_Tup :: ∀ a. ToPg a -> ToPg (Tup a)
toPg_Tup toPg (Tup a) = toPg a # un PgExpr # encloseWith "(" ")" # PgExpr

-- class ToPg a where
--   toPg :: a -> PgExpr

-- instance toPg_PgExpr :: ToPg PgExpr where
--   toPg = identity

-- instance toPg_String :: ToPg String where
--   toPg = PgExpr

-- instance toPg_Boolean :: ToPg Boolean where
--   toPg = PgExpr <<< case _ of
--     true -> "t"
--     false -> "f"

-- instance toPg_Number :: ToPg Number where
--   toPg = show >>> PgExpr

-- instance toPg_Int :: ToPg Int where
--   toPg = show >>> PgExpr

-- instance toPg_Maybe :: ToPg a => ToPg (Maybe a) where
--   toPg = case _ of
--     Nothing -> PgExpr "null"
--     Just v -> toPg v

-- instance toPg_Array :: ToPg a => ToPg (Array a) where
--   toPg = map (toPg >>> un PgExpr) >>> map (escape ["{", ",", "}"]) >>> intercalate "," >>> encloseWith "{" "}" >>> PgExpr

-- instance toPg_Set :: (Ord a, ToPg a) => ToPg (Set a) where
--   toPg = Set.toUnfoldable >>> Array.sort >>> toPg

-- instance toPg_Tup :: InnerTup a => ToPg (Tup a) where
--   toPg (Tup a) = toPg_inner a # un PgExpr # encloseWith "(" ")" # PgExpr

-- class InnerTup a where
--   toPg_inner :: a -> PgExpr

-- instance innerTup_empty :: InnerTup Unit where
--   toPg_inner _ = PgExpr ""

-- else instance innerTup_recr :: (ToPg a, InnerTup b) => InnerTup (a /\ b) where
--   toPg_inner (a /\ b) =
--     let
--       a' = escape ["(", ",", ")"] $ un PgExpr $ toPg a
--       b' = un PgExpr $ toPg_inner b
--     in PgExpr $ a' <> "," <> b'

-- else instance innerTup_base :: ToPg a => InnerTup a where
--   toPg_inner a = PgExpr $ escape ["(", ",", ")"] (un PgExpr $ toPg a)
