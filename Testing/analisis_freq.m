clear all;
j = 0;

fit_t = fittype('sin1');
%fit_t = fittype('fourier1');

Fs = 44250.48767;
Ts = 1/Fs;
for i=1100:1000:20000;
    file_name=['./measures/SINv1/freq_' num2str(i) '.mat'];
    a = load(file_name);
    t = 0:Ts:(numel(a.measures)-1)*Ts;
    a.measures = a.measures-mean(a.measures);
    fit_curve = fit(t',a.measures,fit_t);
    seno = fit_curve.a1*sin(fit_curve.b1*t+fit_curve.c1);
    e = a.measures'-seno;
    
    plot(t,a.measures,'-');
    hold on;
    plot(t,seno,'o');
    plot(t,e,'r');
    hold off;
    fprintf ('Freq: %f, SNR: %f, ',fit_curve.b1/(2*pi),10*log10(sum((seno).^2)/sum((e).^2)));
    
    N = numel(a.measures);
    freq = a.conf.freq;
    
    spec = abs(fft(a.measures.*flattopwin(numel(a.measures))))/N;
    f = 0: Fs/N :(N-1)*Fs/N;
    plot(f,db(spec));
    hold on;
    k=1;
    harm = [];
     for j=freq:freq:Fs/2
         idx= (j - 2*Fs/N < f  & f < j + 2*Fs/N);
         harm(k)=max(spec(idx));
         plot(f(spec==harm(k)),db(spec(spec==harm(k))),'ro');
         k = k+1;
     end
     
     fprintf ('THD: %f\n',10*log10(sum(harm(2:numel(harm)).^2)/(harm(1).^2)));
     hold off;
    
    
end