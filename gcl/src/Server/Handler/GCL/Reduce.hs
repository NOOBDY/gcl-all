{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE NamedFieldPuns #-}

module Server.Handler.GCL.Reduce where

import qualified Data.Aeson.Types as JSON
import Debug.Trace
import GHC.Generics (Generic)
import Server.Monad (ServerM)
import Syntax.Typed.Reduce (Redex)

data ReduceParams = ReduceParams
  { po :: Int,
    redex :: Redex
  }
  deriving (Eq, Show, Generic)

instance JSON.FromJSON ReduceParams

instance JSON.ToJSON ReduceParams

handler :: ReduceParams -> ServerM ()
handler ReduceParams {po, redex} = trace (show po <> " " <> show redex) $ return ()
