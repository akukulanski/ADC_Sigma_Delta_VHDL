clear all;
j = 0;


volt = 0:0.003:3.3;
for i= 0.0:0.003:3.3;
    file_name=['./measures/DC_FullTest/offset_' num2str(i) '.mat'];
    %file_name=['/home/ariel/git/vhdl-adc/Testing/measures/DCv2/offset_' num2str(i) '.mat'];
    m = load(file_name);
    j=j+1;
    lin(j) = median(m.measures);
    v(j) = mad(m.measures);
    v2(j) = std(m.measures);
end
figure;



[r m b] = regression(volt(volt>0.2 & volt<3),lin(volt>0.2 & volt<3));

reg = m*volt+b;
e = (reg - lin);

ee= interp1(lin,e,min(lin):max(lin),'spline');
plot(min(lin):max(lin),ee)
amp = min(lin):max(lin);
save('error_curve.mat','ee','amp');
figure;

a(1)=subplot(311);
plot(volt,lin,'-');
hold on;
plot(volt,reg,'-r');
hold off;
a(2)=subplot(312);
plot(volt,v2,'-');
a(3)=subplot(313);
plot(volt,e,'-');

linkaxes(a,'x');
% 
% %lin = lin/max(abs(lin)) *1.65 + 1.65
% xp1 = 0.7;
% xp2 = 0.9;
% 
% [r m b] = regression(volt(volt>xp1 & volt<xp2),lin(volt>xp1 & volt<xp2));
% e = ((m*volt+b) - lin);
% 
% 
% x1 = 1.67;
% x2 = 1.68;
% % 
% % x1 = 1;
% % x2 = 2;
% 
% minv = min(volt(volt>x1 & volt<x2));
% maxv = max(volt(volt>x1 & volt<x2));
% 
% aux = lin(volt>x1 & volt<x2);
% xx = minv:0.0001:maxv;
% ee= interp1(volt(volt>x1 & volt<x2),e(volt>x1 & volt<x2),xx,'linear');
% linlin=interp1(1:numel(aux),aux,linspace(1,numel(aux),numel(xx)),'linear');
% 
% pol_ord = 1;
% pol_ord_t = ['poly' num2str(pol_ord)];
% 
% fit_t = fittype(pol_ord_t);
% fit_curve = fit(linlin',ee',fit_t);
% 
% 
% aux = lin(volt>x1 & volt<x2);
% 
% 
% for i=0:pol_ord
%     lin(volt>x1 & volt<x2) = lin(volt>x1 & volt<x2) + fit_curve.(['p' num2str(i+1)]) * aux.^(pol_ord-i) ;
% end
% 
% [er em eb] = regression(lin(volt>=x2),e(volt>=x2));
% lin(volt>=x2) = lin(volt>=x2)+lin(volt>=x2)*em+eb;
% [r m b] = regression(volt(volt>1.65-1&volt<1.65+1),lin(volt>1.65-1&volt<1.65+1));
% e = ((m*volt+b) - lin);
% 
% y1 = lin(volt==minv);
% y2 = lin(volt==maxv);
% 
% save('curve_correction.mat','y1','y2','pol_ord','fit_curve','er','em','eb');
% 
% figure;
% p(1) = subplot(311);
% plot(volt,lin,'x');
% hold on;
% plot(volt,m*volt+b,'-r');
% hold off;
% p(2) = subplot(312);
% plot(volt,e,'r');
% 
% fprintf('Max Error: %f, Rel: %f\n',max(e),max(e)/max(lin));
% fprintf('Mean Error: %f, Rel: %f\n',mean(e),mean(e)/max(lin));
% fprintf('Min Error: %f, Rel: %f\n',min(e),min(e)/max(lin));
% p(3) = subplot(313);
% plot(volt,v);
% hold on;
% plot(volt,v2,':r');
% hold off;
% 

%linkaxes(p,'x');