% FOR REFERENCE ONLY. I TRIED THIS AND NOTICED WHY IT IS UNFEASIBLE.

clear all; close all; clc;
addpath('dataimport/');

traints=importraw;
testdata = importrawt;


singlesequence = cell2mat(traints{1}'); % Concat. all data to 1 sequence for HMM.
seqdirtmp = traints{3};

% Must duplicate direction for each entry.
seqdirs = zeros(1,size(singlesequence,1));
cellsz = cellfun(@size,traints{1},'uni',false);

seqdirs(1:cellsz{1}(1)) = seqdirtmp(1);
cnt = cellsz{1}(1);

trsmtx = zeros(4,4); % MLE transition probability estimates.
for k = 2 : size(traints{1},2)
    
    trsmtx(dir2num(seqdirtmp(k-1)),dir2num(seqdirtmp(k))) = trsmtx(dir2num(seqdirtmp(k-1)),dir2num(seqdirtmp(k))) + 1;
    
    seqdirs(cnt+1:cnt+cellsz{k}(1)) = seqdirtmp(k);
    cnt = cnt + cellsz{k}(1);
end

for i = 1 : 4
    trsmtx(i,:) = trsmtx(i,:)./sum(trsmtx(i,:));
end

% seq1 = hmmgenerate(100,trsmtx,singlesequence);
% [estTR,estE] = hmmtrain(seq1,trsmtx,singlesequence);

onlyz = singlesequence(:,10);
onlyz = onlyz + abs(min(onlyz))+1;
onlyz = round(100*onlyz);
[TRANS,EMIS] = hmmestimate(onlyz,seqdirs','Pseudoemissions',1e-5*ones(9,length(onlyz)),'Pseudotransitions',1e-5*ones(9,9));
[estTR,estE] = hmmtrain(onlyz,TRANS,EMIS);  % THIS PART NEVER ENDS DUE TO REASONS EXPLAINED IN REPORT.


% Now work on test data.
singlesequence_test = cell2mat(testdata{1}');

onlyz = (singlesequence_test(:,10)-min(onlyz))/max(singlesequence_test(:,10));
onlyz = onlyz + abs(min(onlyz))+1;
onlyz = round(100*onlyz);

STATES = hmmviterbi(onlyz,TRANS,EMIS);
