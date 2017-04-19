clear all; close all; clc;
addpath('dataimport/');

[traindata,trainmean,trainstd] = importdatasetf; %import training dataset
[testx,testdirs,testd] = importtestf(trainmean,trainstd);

% MATLAB DOES TEST & TRAIN SPLIT BY ITSELF.

traindata=[traindata;[testx testdirs testd]];
traindata=[traindata;traindata;traindata];

trainfeats = traindata(:,1:end-2);
traindists = round(100*(traindata(:,end))/1e2)/100;
traindirs = traindata(:,end-1);

% RUN NN APP FROM MATLAB'S TOOLBOX.