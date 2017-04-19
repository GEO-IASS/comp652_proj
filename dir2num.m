function [ output_args ] = dir2num( input_args )
%DÝR2NUM Summary of this function goes here
%   Detailed explanation goes here

if input_args==1
    output_args = 1;
elseif input_args==3
    output_args = 2;
elseif input_args==7
    output_args = 3;
elseif input_args==9
    output_args = 4;
else 
        return;
end 


end

