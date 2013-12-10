{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveDataTypeable #-}

-----------------------------------
-- acid-state code for Reffit
-----------------------------------

module Reffit.AcidTypes where

import Reffit.Types
import Reffit.DataVersion

import Control.Monad.IO.Class (liftIO)
import Control.Monad.Reader (asks)
import Data.ByteString (ByteString)
import Control.Lens (makeLenses, view,over) 
import Data.SafeCopy (base, deriveSafeCopy)
import qualified Data.Text as T hiding (head)
import GHC.Generics
import Data.Typeable (Typeable)
import Data.List
import GHC.Int
import Data.Hashable
import qualified Data.Map as Map
import Snap.Util.FileServe (serveDirectory)
import Snap (SnapletInit, Snaplet, Handler,
             addRoutes, nestSnaplet, serveSnaplet,
             defaultConfig, makeSnaplet,
             snapletValue, writeText, modify, gets)
import Snap.Snaplet.AcidState (Update, Query, Acid, 
                                HasAcid (getAcidStore),
                                makeAcidic, update,
                                query, acidInit)

data PersistentState = PersistentState {
    _documents :: [Document]
  , _users     :: Map.Map T.Text User
  } deriving (Show, Generic, Typeable)
  
makeLenses ''PersistentState

deriveSafeCopy scv 'base ''PersistentState

-- TODO: Check that document title isn't already taken
addDocument :: Maybe T.Text -> T.Text  -> [T.Text] -> T.Text -> DocClass -> 
               Update PersistentState ()
addDocument dUploader dTitle dAuthors dLink dClass = do
  oldDocs <- gets _documents
  let newDoc = Document
               dUploader newId dTitle dAuthors dLink dClass [] [] Map.empty
      newId = head $ filter (`notElem` (map docId oldDocs))
              [tHash, tLen, tNotTaken]
      tHash = fromIntegral . hash  $ dTitle :: Int32
      tLen  = fromIntegral (length oldDocs)  :: Int32
      tNotTaken = head $[0..maxBound] \\ (map docId oldDocs) :: Int32
  modify (over documents ( newDoc : ))

-- TODO - how can I alert the caller that there's already
-- a user by that name?
-- There SHOULDN'T be, because addUser should only get called
-- when a NEW user registers an account and gets an Auth
-- username.  But seems safer to check and report this assumption
addUser :: UserName -> Update PersistentState ()
addUser uName = do
  allUsers <- gets _users
  case Map.lookup uName allUsers of
    Nothing ->
      modify (over users ( Map.insert uName $ User uName [] [] ))
    Just _ -> do  -- This checks and refuses to overwrite, but silently
      modify (over users id)

queryAllDocs :: Query PersistentState [Document]
queryAllDocs = asks _documents

queryAllUsers :: Query PersistentState (Map.Map T.Text User)
queryAllUsers = asks _users

makeAcidic ''PersistentState ['addDocument, 'queryAllDocs, 'queryAllUsers, 'addUser]