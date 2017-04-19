% close all,clear all,clc;



%% import test data
testdata={};
testlocs={};
iter=1;
S = dbstack('-completenames');
datapath=strrep(S(1).file,strcat(S(1).name,'.m'),'');

for k = 1:11%no = 1:11 
    alltxt = dir(sprintf('%s/tests/*.txt',datapath));
    %for k=1:size(alltxt,1)
        %read measurements
        testdata{iter}=importdata(sprintf('%s/tests/%s',datapath,alltxt(k).name));
        %read location (lat&long) info
        f = fopen(sprintf('%s/tests/%s',datapath,alltxt(k).name));
        formatSpec = '%f %f %f %f %d %d';
        testlocs{iter} = textscan(f,formatSpec,'HeaderLines',size(testdata{iter},1)+1);
        fclose(f);
        iter = iter + 1;
    %end
end


%% == FEATURE EXTRACTION ==%%
%extract test features
testfeatures=[];
testdistances=[];
testdirs=[];
for iter = 1:size(testdata,2)
    beginidx = cell2mat(testlocs{iter}(end-1)) + 1;
    endidx = cell2mat(testlocs{iter}(end)) + 1;
    
    %travelled distance info
    tmploc=testlocs{iter};
    lat1 = cell2mat(tmploc(1));
    lon1 = cell2mat(tmploc(2));
    lat2 = cell2mat(tmploc(3));
    lon2 = cell2mat(tmploc(4));

    for k = 1:size(beginidx,1)
        %magnetometer xyz-axis feature extraction
        
        if endidx(k)>size(testdata{iter},1), lastidx = endidx(k)-1; else lastidx = endidx(k); end 
        
        avg_f = mean(testdata{iter}(beginidx(k):lastidx,2:4));
        var_f = var(testdata{iter}(beginidx(k):lastidx,2:4));
        med_f = median(testdata{iter}(beginidx(k):lastidx,2:4));
        e_f = sum(abs(fft(testdata{iter}(beginidx(k):lastidx,2:4)))) ./ double(lastidx - beginidx(k));
        
        
        testfeatures = [testfeatures;avg_f var_f med_f e_f];
        
        cmdistance = 1e5 * haversine( [lat1(k) lon1(k)], [lat2(k) lon2(k)]);%distance in centimeters
        testdistances = [testdistances;cmdistance];% {numsamples} = cmdistance;
        
        
        %direction of movement
        if lat1(k) == lat2(k), up = 0; elseif lat1(k) > lat2(k), up = -1; else up = +1; end
        if lon1(k) == lon2(k), right = 0; elseif lon1(k) > lon2(k), right = -1; else right = +1; end
        testdirs = [testdirs;movementdirection(up,right)];
    end
end


%% GENERATION OF TRAINING VECTORS
% [coeff,score] = pca(nrmdata);
% reducedDimension = coeff(:,1:8);
% reducedData = nrmdata * reducedDimension;




Mdl = fitcknn(trainingcombined(:,1:end-1),trainingcombined(:,end),'NumNeighbors',23);
%Mdl = fitcsvm(trainingcombined(:,1:end-1),trainingcombined(:,end),'KernelFunction','rbf','Standardize',true,'ClassNames',{'negClass','posClass'});
%Mdl = fitcecoc(trainingcombined(:,1:end-1),trainingcombined(:,end));

testfeatures = (testfeatures - repmat(trainmean,size(testfeatures,1),1))./repmat(trainstd,size(testfeatures,1),1);


[label,score] = predict(Mdl,trainingcombined(:,1:end-1));
accuracy =  size(find(label == trainingcombined(:,end)),1)/size(trainingcombined,1) * 100



[label,score] = predict(Mdl,testfeatures);
accuracy =  size(find(label == testdirs),1)/size(testdirs,1) * 100





