{-# LANGUAGE OverloadedStrings #-}

module Server.Reduce where

import Control.Lens
import Control.Monad.State (evalState)
import qualified Data.Text as Text
import Error (Error (..))
import GCL.Predicate (PO (..))
import Pretty.Error ()
import Prettyprinter (layoutCompact, pretty)
import Prettyprinter.Render.Text (renderStrict)
import Server.FileState (FileState (..))
import Server.Monad
  ( ServerM,
    getFileState,
    getPendingEdit,
    logTextLn,
    sendWindowInfoMessage,
    setFileState,
  )
import Server.Notification.Update (sendFileState)
import Syntax.Typed.Reduce (Redex, reduce)
import qualified Syntax.Typed.Types as T

-- TODO: add env for function inline
evalReduce :: T.Expr -> Redex -> T.Expr
evalReduce predicate redex = evalState (Syntax.Typed.Reduce.reduce [] predicate redex) (0 :: Int)

reduce :: FilePath -> Int -> Redex -> ServerM ()
reduce filePath poIndex redex = do
  maybePending <- getPendingEdit filePath
  case maybePending of
    Just _ -> do
      logTextLn "Reduce: pending edit exists, skipping"
      sendWindowInfoMessage "GCL: busy, please retry"
    Nothing -> do
      maybeFs <- getFileState filePath
      let result = do
            fs <- case maybeFs of
              Nothing -> Left [Others "Reduce" "File not loaded." Nothing]
              Just fs -> return fs

            let pos = fsProofObligations fs
            let po = pos ^?! element poIndex
            let pred' = poReducedPred po
            let reducedPred = evalReduce pred' redex
            let po' = po {poReducedPred = reducedPred}
            let fs' = fs {fsProofObligations = pos & element poIndex .~ po'}

            return fs'

      case result of
        Left errs -> sendWindowInfoMessage (Text.intercalate "\n" $ map (renderStrict . layoutCompact . pretty) errs)
        Right fs' -> do
          setFileState filePath fs'
          sendFileState filePath fs'
