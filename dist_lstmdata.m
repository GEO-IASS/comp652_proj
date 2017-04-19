clear all; close all; clc;
addpath('dataimport/');

traints=importraw;
testdata = importrawt;
testnum=2972;


distance_timeseries = cell2mat(traints{1}');

% Must duplicate direction for each entry.
seqdirs = zeros(size(distance_timeseries,1),1);
cellsz = cellfun(@size,traints{1},'uni',false);
seqdirtmp = traints{3};

seqdirs(1:cellsz{1}(1)) = seqdirtmp(1);
cnt = cellsz{1}(1);
for k = 2 : size(traints{1},2)
    seqdirs(cnt+1:cnt+cellsz{k}(1)) = seqdirtmp(k);
    cnt = cnt + cellsz{k}(1);
end
seqdirs(seqdirs==3) = 2;
seqdirs(seqdirs==7) = 3;
seqdirs(seqdirs==9) = 4;


% distance_timeseries = [distance_timeseries(:,end-2:end) seqdirs];
% return
% 

% WRITE X_TRAIN
distance_timeseries = distance_timeseries(:,2:end);
% Normalize.
for k=1 : size(distance_timeseries, 2)
    tmpcol = distance_timeseries(:,k);
    tmpcol = (tmpcol - min(tmpcol)) / ( max(tmpcol) - min(tmpcol) );
    distance_timeseries(:,k)  = tmpcol;
end

trainset = distance_timeseries;
trainseq = seqdirs;

% TEST SET.
% incorrectguesses = inf;
% while incorrectguesses>testnum/2
% idx=randperm(size(T,2)-testnum-1,1);
% Xst = X(:,idx:idx+testnum); Tst = T(:,idx:idx+testnum);
% [Y,Xf,Af] = sim(net,Xst,Xi,Ai,Tst);
% results = abs(cell2mat(Tst)-cell2mat(Y));
% incorrectguesses = length(find(results>=0.5));
% end
distance_timeseries = cell2mat(testdata{1}');
distance_timeseries = distance_timeseries(:,2:end);

% Must duplicate direction for each entry.
seqdirs = zeros(size(distance_timeseries,1),1);
cellsz = cellfun(@size,testdata{1},'uni',false);
seqdirtmp = testdata{3};

seqdirs(1:cellsz{1}(1)) = seqdirtmp(1);
cnt = cellsz{1}(1);
for k = 2 : size(testdata{1},2)
    seqdirs(cnt+1:cnt+cellsz{k}(1)) = seqdirtmp(k);
    cnt = cnt + cellsz{k}(1);
end
seqdirs(seqdirs==3) = 2;
seqdirs(seqdirs==7) = 3;
seqdirs(seqdirs==9) = 4;

distance_timeseries = [trainset ; ];
seqdirs = [trainseq ; ];

X = con2seq(distance_timeseries');
T = con2seq(seqdirs');

net = layrecnet(1:25,5);
[Xs,Xi,Ai,Ts] = preparets(net,X,T);
net = train(net,Xs,Ts,Xi,Ai);
%perf = perform(net,Y,Ts);
% TRAIN SET.
[Y,Xf,Af] = sim(net,X,Xi,Ai,T);
results = abs(cell2mat(Y)-cell2mat(T));
incorrectguesses = length(find(results>=0.5));
fprintf('\n TRAINING: Incorrect guesses: %d/%d, Accuracy: %.4f%% ', incorrectguesses,size(Y,2), 100*(size(Y,2)-incorrectguesses)/size(Y,2));

% TEST SET.
% incorrectguesses = inf;
% while incorrectguesses>testnum/2
% idx=randperm(size(T,2)-testnum-1,1);
% Xst = X(:,idx:idx+testnum); Tst = T(:,idx:idx+testnum);
% [Y,Xf,Af] = sim(net,Xst,Xi,Ai,Tst);
% results = abs(cell2mat(Tst)-cell2mat(Y));
% incorrectguesses = length(find(results>=0.5));
% end

[Y,Xf,Af] = sim(net,Xs,Xf,Af,Ts);
results = abs(cell2mat(Ts)-cell2mat(Y));
incorrectguesses = length(find(results>=0.5));
fprintf('\n TEST: Incorrect guesses: %d/%d, Accuracy: %.4f%% ', incorrectguesses,size(Y,2), 100*(size(Y,2)-incorrectguesses)/size(Y,2));


return

% save('X_train.txt', 'distance_timeseries','-ASCII');
fid = fopen('X_train.txt', 'w');
fprintf(fid,'%f %f %f %f %f %f %f %f %f\n',distance_timeseries);
fclose(fid);

fid = fopen('y_train.txt', 'w');
fprintf(fid,'%d \n',seqdirs);
fclose(fid);


%%TEST
fid = fopen('X_test.txt', 'w');
fprintf(fid,'%f %f %f %f %f %f %f %f %f\n',distance_timeseries(2000:6000,:));
fclose(fid);

fid = fopen('y_test.txt', 'w');
fprintf(fid,'%d \n',seqdirs(2000:6000));
fclose(fid);



return

%%TEST
distance_timeseries = cell2mat(testdata{1}');

% Must duplicate direction for each entry.
seqdirs = zeros(size(distance_timeseries,1),1);
cellsz = cellfun(@size,traints{1},'uni',false);
seqdirtmp = traints{3};

seqdirs(1:cellsz{1}(1)) = seqdirtmp(1);
cnt = cellsz{1}(1);
for k = 2 : size(traints{1},2)
    seqdirs(cnt+1:cnt+cellsz{k}(1)) = seqdirtmp(k);
    cnt = cnt + cellsz{k}(1);
end
seqdirs(seqdirs==3) = 2;
seqdirs(seqdirs==7) = 3;
seqdirs(seqdirs==9) = 4;





% WRITE X_TEST
distance_timeseries = distance_timeseries(:,2:end);
% Normalize.
for k=1 : size(distance_timeseries, 2)
    tmpcol = distance_timeseries(:,k);
    tmpcol = (tmpcol - min(tmpcol)) / ( max(tmpcol) - min(tmpcol) );
    distance_timeseries(:,k)  = tmpcol;
end
% save('X_test.txt', 'distance_timeseries','-ASCII');
fid = fopen('X_test.txt', 'w');
fprintf(fid,'%f %f %f %f %f %f %f %f\n',distance_timeseries);
fclose(fid);

fid = fopen('y_test.txt', 'w');
fprintf(fid,'%d \n',seqdirs);
fclose(fid);