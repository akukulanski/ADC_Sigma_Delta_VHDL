fp=4.3307e3;%frec. de corte
fs=45.3125e6;%frec. de sampling
% 150k 470p+20p=490p, al hacer superposición quedan 2 de 150k en paralelo
wp=2*pi*fp;
Trc=1/wp;%constante de tiempo filtro
%Trc=10;
Ts=1/fs;
H=@(f) 1/2./(1+1j*2*pi*Trc*f);
%H=@(f) 1./(1i*2*pi*Trc*f);
%G=abs(1/feval(H,fs/2));
G=1650;
%G=3.3/3e-3;
Heq=@(f) 1/2 * (1-exp(-Ts/Trc))./(1-exp(-Ts/Trc)*exp(-1i*2*pi*f*Ts));
%Heq=@(f) 1/2 * (1-exp(-Ts/Trc))./(exp(1i*2*pi*f*Ts)-exp(-Ts/Trc));
%Heq=@(f) exp(-1i*2*pi*f*Ts)./(1-exp(-1i*2*pi*f*Ts));
Fs=0:2000:fs;
Fp=0:1:11000;
Fa=fs-11000:1:fs+11000;

%figure(5);
%plot(Fp,20*log10( abs( feval(Heq,Fp) ) ) );

Hn=@(f) 1./(1+G*feval(Heq,f));
Hx=@(f) G*feval(H,f).*feval(Hn,f);
figure(1);
subplot(2,2,[1,2]);
plot(Fp/1000,20/log(10)*log( abs( feval(Hx,Fp) ) ) );
xlabel('frec[kHz]','FontSize',12,'FontWeight','bold');
ylabel('H_X[dB]','FontSize',12,'FontWeight','bold');
set(gca,'fontsize',12);
subplot(223);
plot(Fp/1000,20/log(10)*log( abs( feval(Hn,Fp) ) ) );
xlabel('frec[kHz]','FontSize',12,'FontWeight','bold');
ylabel('H_N[dB]','FontSize',12,'FontWeight','bold');
set(gca,'fontsize',12);
subplot(224);
plot(Fa/1e6,20/log(10)*log( abs( feval(Hx,Fa) ) ) );
xlabel('frec[MHz]','FontSize',12,'FontWeight','bold');
ylabel('H_X[dB]','FontSize',12,'FontWeight','bold');
set(gca,'fontsize',12);
%figure(2);
%plot(Fp,20/log(10)*log( abs( feval(Hn,Fp) ) ) );
%figure(3);
%plot(Fs,20/log(10)*log( abs( feval(Hx,Fs) ) ) );
%figure(4);
%plot(Fs,20/log(10)*log( abs( feval(Hn,Fs) ) ) );

int= integral(@(f) abs(feval(Hn,f)).^2,0,fp);
int
(min(abs(feval(Hx,Fp))))^2
SQNR= (min(abs(feval(Hx,Fp))))^2/(1.65^2*int/12/11e3);
10*log(SQNR)/log(10)
(ans-1.76)/6.02


