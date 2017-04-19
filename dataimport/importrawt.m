function testdata = importrawt

%% Import test.
testdata={};
testlocs={};
iter=1;
S = dbstack('-completenames');
datapath=strrep(S(1).file,strcat(S(1).name,'.m'),'');

%% Import test data.
testdata={};
testlocs={};
iter=1;
for k = 1 : 11
    alltxt = dir(sprintf('%s/tests/*.txt',datapath));
        testdata{iter}=importdata(sprintf('%s/tests/%s',datapath,alltxt(k).name));
        % Read location (lat&long) info.
        f = fopen(sprintf('%s/tests/%s',datapath,alltxt(k).name));
        formatSpec = '%f %f %f %f %d %d';
        testlocs{iter} = textscan(f,formatSpec,'HeaderLines',size(testdata{iter},1)+1);
        fclose(f);
        iter = iter + 1;
end


testdata2={}; iter = 1;
for k = 1 : 11
    startlocs = cell2mat(testlocs{k}(5))+1;
    endlocs = cell2mat(testlocs{k}(6))+1;
    curtext = testdata{k};
    for j = 1 : size(startlocs,1)
        testdata2{iter} = curtext(startlocs(j):endlocs(j),:);
        iter = iter + 1;
    end
end

%% == FEATURE EXTRACTION ==%%

% Extract test features.
testfeatures=[];
testdistances=[];
testdirs=[];
for iter = 1:size(testdata,2)
    
    beginidx = cell2mat(testlocs{iter}(end-1)) + 1;
    endidx = cell2mat(testlocs{iter}(end)) + 1;
    
    % Travelled distance info.
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


testdistances_2=cell(size(testdata,2),1);
for k = 1:size(testdata,2)
   numsteps=size(testdata{k},1);
   increm=testdistances(k)/numsteps;
   testdistances_2{k} = increm.*(1:numsteps)';
end


%% GENERATION OF TRAINING VECTORS

testdata = { testdata2; testdistances_2; testdirs };

end