clear all;
close all;
j = 0;

fit_t = fittype('sin1');
%fit_t = fittype('fourier1');

Fs = 44250.48767/2;
Ts = 1/Fs;
l=1;
for i=logspace(1,log10(11e3),100);
    file_name=['./measures/SIN_FullTest2/freq_' num2str(i) '.mat'];
    a = load(file_name);
    t = 0:Ts:(numel(a.measures)-1)*Ts;
    a.measures = linearity_correction(a.measures);
    
    a.measures = a.measures-mean(a.measures);
    fit_curve = fit(t',a.measures,fit_t);
    seno = fit_curve.a1*sin(fit_curve.b1*t+fit_curve.c1);
    e = a.measures'-seno;
    
    %plot(t,a.measures,'-');
    
    fprintf ('Freq: %f, SNR: %f, ',fit_curve.b1/(2*pi),10*log10(sum((seno).^2)/sum((e).^2)));
    f_axe(l) = fit_curve.b1/(2*pi);
    bits(l) = (10*log10(sum((seno).^2)/sum((e).^2)) -1.76)/6.02;
    
    N = numel(a.measures);
    freq = a.conf.freq;
    
    spec = abs(fft(a.measures.*flattopwin(numel(a.measures))))/N;
    f = 0: Fs/N :(N-1)*Fs/N;
%     plot(f,db(spec));
%     hold on;
    k=1;
    harm = [];
     for j=freq:freq:Fs/2
         idx= (j - 2*Fs/N < f  & f < j + 2*Fs/N);
         harm(k)=max(spec(idx));
         %plot(f(spec==harm(k)),db(spec(spec==harm(k))),'ro');
         k = k+1;
     end
     
     %ylim([-30 80]);
     thd(l) = sum(harm(2:numel(harm)).^2)/(harm(1).^2)*100;
     %fprintf ('THD: %f\n',-10*log10(sum(harm(2:numel(harm)).^2)/(harm(1).^2)));
     %hold off;
    
    l = l+1;
end
figure;
%semilogx(f_axe(1:numel(bits)-1),bits(1:numel(bits)-1),'b');
semilogx(f_axe(1:numel(bits)-1),thd(1:numel(bits)-1),'b');
hold on;



j = 0;

fit_t = fittype('sin1');
%fit_t = fittype('fourier1');

Fs = 44250.48767/2;
Ts = 1/Fs;
l=1;

for i=logspace(1,log10(11e3),100);
    file_name=['./measures/SIN_FullTest2/freq_' num2str(i) '.mat'];
    a = load(file_name);
    t = 0:Ts:(numel(a.measures)-1)*Ts;
    
    a.measures = a.measures-mean(a.measures);
    fit_curve = fit(t',a.measures,fit_t);
    seno = fit_curve.a1*sin(fit_curve.b1*t+fit_curve.c1);
    e = a.measures'-seno;
    
    fprintf ('Freq: %f, SNR: %f, ',fit_curve.b1/(2*pi),10*log10(sum((seno).^2)/sum((e).^2)));
    f_axe(l) = fit_curve.b1/(2*pi);
    bits(l) = (10*log10(sum((seno).^2)/sum((e).^2)) -1.76)/6.02;
    
    N = numel(a.measures);
    freq = a.conf.freq;
   
    spec = abs(fft(a.measures.*flattopwin(numel(a.measures))))/N;
    f = 0: Fs/N :(N-1)*Fs/N;
    % plot(f,db(spec));
    % hold on;
    k=1;
    harm = [];
     for j=freq:freq:Fs/2
         idx= (j - 2*Fs/N < f  & f < j + 2*Fs/N);
         harm(k)=max(spec(idx));      
         %plot(f(spec==harm(k)),db(spec(spec==harm(k))),'ro');  
         k = k+1;
     end
     
     %ylim([-30 80]);
     %hold off;
     thd(l) = sum(harm(2:numel(harm)).^2)/(harm(1).^2)*100;
     %fprintf ('THD: %f\n',-10*log10(sum(harm(2:numel(harm)).^2)/(harm(1).^2)));
     
    l = l+1;
end
%semilogx(f_axe(1:numel(bits)-1),bits(1:numel(bits)-1),'r');
semilogx(f_axe(1:numel(bits)-1),thd(1:numel(bits)-1),'r');

hold off;
