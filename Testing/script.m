clear all;
j = 0;
volt = 0.01:0.01:3.3;
for i=0.01:0.01:3.3;
    file_name=['./measures/DCv2/offset_' num2str(i) '.mat'];
    %file_name=['/home/ariel/git/vhdl-adc/Testing/measures/DCv2/offset_' num2str(i) '.mat'];
    a = load(file_name);
    j=j+1;
    lin(j) = median(a.measures);
    v(j) = mad(a.measures);
    v2(j) = std(a.measures);
end

%lin = lin/max(abs(lin)) *1.65 + 1.65

[r m b] = regression(volt,lin);
e = abs((m*volt+b) - lin);

p(1) = subplot(211);
plot(volt,lin,'o-');
hold on;
plot(volt,e,'r');
maxe = max(e);
idx = e==maxe;
plot(volt(idx),lin(idx),'o');
hold off;

fprintf('Max Error: %f, Rel: %f\n',max(e),max(e)/max(lin));
fprintf('Mean Error: %f, Rel: %f\n',mean(e),mean(e)/max(lin));
fprintf('Min Error: %f, Rel: %f\n',min(e),min(e)/max(lin));
p(2) = subplot(212);
plot(volt,v);
hold on;
plot(volt,v2,':r');
hold off;


linkaxes(p,'x');