clear all; close all; clc;
addpath('dataimport/');

[traindata,trainmean,trainstd] = importdatasetf; %import training dataset
[testx,testdirs,testd] = importtestf(trainmean,trainstd);

traindata_2 = traindata(:,10:13);

% USE MATLAB'S CLASSIFICATION LEARNER.

