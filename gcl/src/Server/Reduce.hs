{-# LANGUAGE OverloadedStrings #-}

module Server.Reduce where

import Syntax.Typed.Reduce (Redex)
import Server.Monad (ServerM, getPendingEdit, readSourceAndVersion, sendWindowInfoMessage)
import Debug.Trace

reduce :: FilePath -> Int -> Redex -> ServerM ()
reduce filePath po redex = do
  traceM $ show filePath
  traceM $ show po
  traceM $ show redex
  return ()
  -- maybePending <- getPendingEdit filePath
  -- case maybePending of
  --   Just _ -> do
  --     logTextLn "Reduce: pending edit exists, skipping"
  --     sendWindowInfoMessage "GCL: busy, please retry"
  --   Nothing -> do
  --     logTextLn $ "Reduce: cursor: " <> Text.pack (show cursor)
  --     maybeFs <- getFileState filePath
  --     maybeSource <- readSourceAndVersion filePath
  --     case maybeSource of
  --       Nothing ->
  --         logText "Reduce: cannot read virtual file\n"
  --       Just (source, vfsVersion) -> return ()



  -- return ()
