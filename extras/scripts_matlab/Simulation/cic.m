function [ output ] = cic( input )
     H = dsp.CICDecimator('DecimationFactor',256, ...
                      'DifferentialDelay',1, ...
                      'NumSections',6, ...
                      'FixedPointDataType','Specify word lengths', ...
                      'SectionWordLengths',[55 55 55 55 55 55 55 55 55 55 55 18], ...
                      'OutputWordLength', 18);
     k = floor(numel(input)/256);
     
     input = fi(input','Signedness','Signed','WordLength',2,'FractionLength',0,'RoundingMethod', 'Floor');
     
     output = step(H,input(1:k*256)); 
     output = output;
% input = fi(input,'Signedness','Unsigned','WordLength',55,'FractionLength',0,'RoundingMethod', 'Floor', 'OverflowAction', 'Wrap');
%      a = integrator(input,55);
%      a = integrator(a,55);     
%      a = integrator(a,55); 
%      a = downsample(a,256);
%      a = comb(a,55);     
%      a = comb(a,55);
%     output = comb(a,55);
    %h = ones(1,256);
    %h1 = conv(conv(conv(conv(conv(h,h),h),h),h),h);
    %output = filter(h1,1,input);
end

