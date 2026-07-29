{-# LANGUAGE TupleSections #-}

module Syntax.ConstExpr where

import Data.Foldable (foldl')
import Data.List (partition)
import Data.Maybe (mapMaybe)
import qualified Data.Set as Set
import GCL.Common (freeVars)
import Syntax.Abstract.Types (Declaration (..), Expr)
import Syntax.Common.Types (Name)

data DeclType = Const | Var
  deriving (Show)

type Env = [(Name, DeclType)]

pickGlobals :: [Declaration] -> ([Expr], [Expr])
pickGlobals decls =
  -- TODO: partition directly in the fold
  partition (isGlobalProp env' Nothing) (mapMaybe extractAssertion decls)
  where
    env' =
      foldl'
        ( \acc decl -> case decl of
            ConstDecl names _ Nothing _ -> map (,Const) names <> acc
            ConstDecl names _ (Just assertion) _ ->
              map
                ( \name ->
                    if isGlobalProp acc (Just name) assertion
                      then (name, Const)
                      else (name, Var)
                )
                names
                <> acc
            VarDecl names _ _ _ -> map (,Var) names <> acc
        )
        []
        decls

    -- An assertion is a global property
    -- if all of its free variables are of CONSTANTS
    -- `Set Name -> Expr -> Bool` would be more elegant
    -- but probably would also be much more expensive
    isGlobalProp :: Env -> Maybe Name -> Expr -> Bool
    isGlobalProp env (Just self) assertion =
      let fv = freeVars assertion -- XXX: why does `freeVars` not consider bound vars?
       in (Set.notMember self fv || all (isConst env) (Set.delete self fv)) -- XXX: is this correct?
    isGlobalProp env Nothing assertion =
      all (isConst env) (freeVars assertion)

    isConst :: Env -> Name -> Bool
    isConst env name =
      case lookup name env of
        Just Const -> True
        Just Var -> False
        Nothing -> error $ "unknown name: " <> show name

    -- Extracts both the assertion and those declared names
    extractAssertion :: Declaration -> Maybe Expr
    extractAssertion (ConstDecl _ _ e _) = e
    extractAssertion (VarDecl _ _ e _) = e
