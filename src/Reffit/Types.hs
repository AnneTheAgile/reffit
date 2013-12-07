{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE DeriveDataTypeable #-}

module Reffit.Types where

import           Data.Text
import qualified Data.Map as Map
import           GHC.Int
import           GHC.Generics
import           Data.Typeable
import           Reffit.DataVersion
import Data.SafeCopy (base, deriveSafeCopy)


data DocClass = DocClass { docClassName :: Text
                         } deriving (Show, Generic, Typeable)
deriveSafeCopy scv 'base ''DocClass

data User = User { userId   :: Int32
                 , userName :: Text
                 } deriving (Show, Eq, Ord, Generic,Typeable)
deriveSafeCopy scv 'base ''User


data UpDownVote = UpVote | DownVote | NeutralVote
                deriving (Show, Generic)
deriveSafeCopy scv 'base ''UpDownVote

data UserUpDownVote = UserUpDownVote { upDownVoteUser :: User
                                     , upDownVoteAnon :: Bool
                                     , upDownVoteVal  :: UpDownVote
                                     } deriving (Show, Generic)
deriveSafeCopy scv 'base ''UserUpDownVote

data Summary = Summary { docSummaryProse :: Text
                       , docSummaryVotes :: [UserUpDownVote]
                       } deriving (Show, Generic)
deriveSafeCopy scv 'base ''Summary

data AttrVote = AttrVote { attrClass :: Text
                         , attrValue :: UserUpDownVote
                         } deriving (Show, Generic)
deriveSafeCopy scv 'base ''AttrVote

data Critique = Critique { critiqueUser     :: User
                         , critiqueAnon     :: Bool
                         , critiqueAttrVote :: AttrVote
                         } deriving (Show, Generic)
deriveSafeCopy scv 'base ''Critique


data FieldTag = FieldTag { fieldTagText :: Text
                         } deriving (Show, Generic)
deriveSafeCopy scv 'base ''FieldTag
                  
data Document = Document { docId        :: Int32
                         , docTitle     :: Text
                         , docLink      :: Text
                         , docClasses   :: [DocClass]
                         , docFieldTags :: [FieldTag]
                         , docSummaries :: [Summary]
                         , docCritiques :: Map.Map User Critique
                         } deriving (Show, Generic, Typeable)
deriveSafeCopy scv 'base ''Document

data CritiqueClass = CritiqueClass { critiqueClassText :: Text
                                   , critiqueClassNick :: Text
                                   } deriving (Show, Generic)
deriveSafeCopy scv 'base ''CritiqueClass