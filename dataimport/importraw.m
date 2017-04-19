function traints = importraw

%% Import curves.
curvedata={};
curvelocs={};
iter=1;
S = dbstack('-completenames');
datapath=strrep(S(1).file,strcat(S(1).name,'.m'),'');

for no = 1:8
    alltxt = dir(sprintf('%s/curves/c%d/*.txt',datapath,no));
    for k=1:size(alltxt,1)
        % Read measurements.
        curvedata{iter}=importdata(sprintf('%s/curves/c%d/%s',datapath,no,alltxt(k).name));
        % Read location (lat&long) info.
        f = fopen(sprintf('%s/curves/c%d/%s',datapath,no,alltxt(k).name));
        formatSpec = '%f %f %f %f %d %d';
        curvelocs{iter} = textscan(f,formatSpec,'HeaderLines',size(curvedata{iter},1)+1);
        fclose(f);
        iter = iter + 1;
    end
end
%% Import lines.
linedata={};
linelocs={};
iter=1;
for no = 1:8 
    alltxt = dir(sprintf('%s/lines/c%d/*.txt',datapath,no));
    for k=1:size(alltxt,1)
        % Read measurements.
        linedata{iter}=importdata(sprintf('%s/lines/c%d/%s',datapath,no,alltxt(k).name));
        % Read location (lat&long) info.
        f = fopen(sprintf('%s/lines/c%d/%s',datapath,no,alltxt(k).name));
        formatSpec = '%f %f %f %f %d %d';
        linelocs{iter} = textscan(f,formatSpec,'HeaderLines',size(linedata{iter},1)+1);
        fclose(f);
        iter = iter + 1;
    end
end


%% == FEATURE EXTRACTION ==%%

%extract curve features
curvefeatures=[];
curvedistances=[];
curvedirs=[];
for iter = 1:size(curvedata,2)
    
    beginidx = cell2mat(curvelocs{iter}(end-1)) + 1;
    endidx = cell2mat(curvelocs{iter}(end)) + 1;
    
    % Travelled distance info.
    tmploc=curvelocs{iter};
    lat1 = cell2mat(tmploc(1));
    lon1 = cell2mat(tmploc(2));
    lat2 = cell2mat(tmploc(3));
    lon2 = cell2mat(tmploc(4));

    for k = 1:size(beginidx,1)
        %magnetometer xyz-axis feature extraction
        
        if endidx(k)>size(curvedata{iter},1), lastidx = endidx(k)-1; else lastidx = endidx(k); end 
        
        avg_f = mean(curvedata{iter}(beginidx(k):lastidx,2:4));
        var_f = var(curvedata{iter}(beginidx(k):lastidx,2:4));
        med_f = median(curvedata{iter}(beginidx(k):lastidx,2:4));
        e_f = sum(abs(fft(curvedata{iter}(beginidx(k):lastidx,2:4)))) ./ double(lastidx - beginidx(k));
        
        curvefeatures = [curvefeatures;avg_f var_f med_f e_f];
        
        cmdistance = 1e5 * haversine( [lat1(k) lon1(k)], [lat2(k) lon2(k)]);%distance in centimeters
        curvedistances = [curvedistances;cmdistance];% {numsamples} = cmdistance;
        
        
        %direction of movement
        if lat1(k) == lat2(k), up = 0; elseif lat1(k) > lat2(k), up = -1; else up = +1; end
        if lon1(k) == lon2(k), right = 0; elseif lon1(k) > lon2(k), right = -1; else right = +1; end
        curvedirs = [curvedirs;movementdirection(up,right)];
    end
end



%extract line features
linefeatures=[];
linedistances=[];
linedirs=[];
for iter = 1:size(linedata,2)
    
    beginidx = cell2mat(linelocs{iter}(end-1)) + 1;
    endidx = cell2mat(linelocs{iter}(end)) + 1;
    
    %travelled distance info
    tmploc=linelocs{iter};
    lat1 = cell2mat(tmploc(1));
    lon1 = cell2mat(tmploc(2));
    lat2 = cell2mat(tmploc(3));
    lon2 = cell2mat(tmploc(4));

    for k = 1:size(beginidx,1)
        %magnetometer xyz-axis feature extraction
        
        if endidx(k)>size(linedata{iter},1), lastidx = endidx(k)-1; else lastidx = endidx(k); end 
        
        avg_f = mean(linedata{iter}(beginidx(k):lastidx,2:4));
        var_f = var(linedata{iter}(beginidx(k):lastidx,2:4));
        med_f = median(linedata{iter}(beginidx(k):lastidx,2:4));
        e_f = sum(abs(fft(linedata{iter}(beginidx(k):lastidx,2:4)))) ./ double(lastidx - beginidx(k));

        linefeatures = [linefeatures;avg_f var_f med_f e_f];
        
        cmdistance = 1e5 * haversine( [lat1(k) lon1(k)], [lat2(k) lon2(k)]);%distance in centimeters
        linedistances = [linedistances;cmdistance];%%linedistances{numsamples} = cmdistance;
        
        %direction of movement
        if lat1(k) == lat2(k), up = 0; elseif lat1(k) > lat2(k), up = -1; else up = +1; end
        if lon1(k) == lon2(k), right = 0; elseif lon1(k) > lon2(k), right = -1; else right = +1; end
        linedirs = [linedirs;movementdirection(up,right)];
        
    end
end


linedistances_2=cell(size(linedata,2),1);
for k = 1:size(linedata,2)
   numsteps=size(linedata{k},1);
   increm=linedistances(k)/numsteps;
   linedistances_2{k} = increm.*(1:numsteps)';
end


curvedistances_2=cell(size(curvedata,2),1);
for k = 1:size(curvedata,2)
   numsteps=size(curvedata{k},1);
   increm=curvedistances(k)/numsteps;
   curvedistances_2{k} = increm.*(1:numsteps)';
end


%% GENERATION OF TRAINING VECTORS

traints = { linedata; linedistances_2; linedirs; ...
           curvedata; curvedistances_2; curvedirs };

end