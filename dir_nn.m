clear all; close all; clc;
addpath('dataimport/');

traints=importraw;
testdata = importrawt;


singlesequence = cell2mat(traints{1}'); % Concat. all data to 1 sequence for HMM.
seqdirtmp = traints{3};

% Must duplicate direction for each entry.
seqdirs = zeros(size(singlesequence,1),1);
cellsz = cellfun(@size,traints{1},'uni',false);

seqdirs(1:cellsz{1}(1)) = seqdirtmp(1);
cnt = cellsz{1}(1);

for k = 2 : size(traints{1},2)
    seqdirs(cnt+1:cnt+cellsz{k}(1)) = seqdirtmp(k);
    cnt = cnt + cellsz{k}(1);
end

ntstool % RUN TIME SERIES NN. 
