function [ x ] = linearity_correction( x )
%LINEARITY_CORRECTION Summary of this function goes here
%   Detailed explanation goes here
%     load('curve_correction.mat');
%     idx1 = x>y1 & x<y2;
%     idx2 = x>=y2;
%     aux = x(idx1);
% 
%     for i=0:pol_ord
%         x(idx1) = x(idx1) + fit_curve.(['p' num2str(i+1)]) * aux.^(pol_ord-i) ;
%     end
%     
%     x(idx2) = x(idx2)+x(idx2)*em+eb;
    load('error_curve.mat');
    x = x + ee(x-min(amp)+1)';
end

