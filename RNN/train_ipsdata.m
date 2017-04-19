clear all; close all; clc;
addpath('../dataimport/');

traints=importraw;
testdata = importrawt;
numiters=100;

%Inputs and outputs have to be matrices where columns=datapoints
%and rows=inputs
P = cell2mat(vertcat(traints{1})')'; % cell2mat(traints{1}'); %traints{1}{:}';
Y = cell2mat(vertcat(traints{2}))'; % cell2mat(traints{2}); %traints{2}{:}';

% Pick test instances.
rndidx=randperm(size(traints{1},2),8);

Ptest = cell2mat(vertcat(testdata{1})')';%cell2mat(traints{1}'); % cell2mat(traints{1}{rndidx}'); %traints{1}{rndidx}';
Ytest = cell2mat(vertcat(testdata{2}))';%cell2mat(traints{2}); %cell2mat(traints{2}{rndidx}); %traints{2}{rndidx}';


%%
%Create NN

%create recurrent neural network with 3 inputs, 2 hidden layers with 
%5 neurons each and 3 outputs
%the NN uses the input data at timestep t-1 and t-2
%The NN has a recurrent connection with delay of 1,2 and 3 timesteps from the output
% to the first layer (and no recurrent connection of the hidden layers)
nn = [size(P,1) 25 15 size(Y,1)];
dIn = [0];
dIntern=[];
dOut=[1];
net = CreateNN(nn,dIn,dIntern,dOut); %alternative: net = CreateNN([3,5,5,2],[0],[],[1]);

%%
%Train with LM-Algorithm
% Train NN with training data P=input and Y=target
% Set maximum number of iterations k_max to 500
% Set termination condition for Error E_stop to 1e-5
% The Training will stop after 500 iterations or when the Error <=E_stop
netLM = train_LM(P,Y,net,numiters,1e-5);
%Calculate Output of trained net (LM) for training and Test Data
y_LM = NNOut(P,netLM); 
ytest_LM = NNOut(Ptest,netLM); 

%%
%Train with BFGS-Algorithm
% Train NN with training data P=input and Y=target
% Set maximum number of iterations k_max to 1000
% Set termination condition for Error E_stop to 1e-5
% The Training will stop after 1000 iterations or when the Error <=E_stop
% measure time dt
netBFGS = train_BFGS(P,Y,net,numiters,1e-5);
%Calculate Output of trained net (LM) for training and Test Data
y_BFGS = NNOut(P,netBFGS); 
ytest_BFGS = NNOut(Ptest,netBFGS); 


%%
%Plot Results
t = (1:size(Y,2)); %480 timesteps in 15 Minute resolution
ttest = (1:size(Ytest,2)); %480 timesteps in 15 Minute resolution

fig = figure();
set(fig, 'Units', 'normalized', 'Position', [0.2, 0.1, 0.6, 0.6])

subplot(221)
title('Test Data')
set(gca,'FontSize',16)
plot(t,Y,'r:','LineWidth',2)
hold on
grid on
plot(t,y_LM,'b','LineWidth',2)
plot(t,y_BFGS,'g','LineWidth',2)
l1 = legend('Train Data','LM output','BFGS output','Location','northoutside','Orientation','horizontal');
set(l1,'FontSize',14)
ylabel('Storage Pressure [bar]')
axis tight

subplot(223)
set(gca,'FontSize',16)
plot(t,Y,'r:','LineWidth',2)
hold on
grid on
plot(t,y_LM,'b','LineWidth',2)
plot(t,y_BFGS,'g','LineWidth',2)
ylabel('el. Power [kW]')
xlabel('time [h]')
axis tight

subplot(222)
title('Train Data')
set(gca,'FontSize',16)
plot(ttest,Ytest,'r:','LineWidth',2)
hold on
grid on
plot(ttest,ytest_LM,'b','LineWidth',2)
plot(ttest,ytest_BFGS,'g','LineWidth',2)
l2 = legend('Test Data','LM output','BFGS output','Location','northoutside','Orientation','horizontal');
set(l2,'FontSize',14)
axis tight

subplot(224)
set(gca,'FontSize',16)
plot(ttest,Ytest,'r:','LineWidth',2)
hold on
grid on
plot(ttest,ytest_LM,'b','LineWidth',2)
plot(ttest,ytest_BFGS,'g','LineWidth',2)
xlabel('time [h]')
axis tight
