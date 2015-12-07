L=(1:4)';
OSR=128:128:4096;
a=pi./(2*OSR);
k=0:3;
int=zeros(4,length(a));
sqnr=zeros(4,length(a));
sqnr_aprox=zeros(4,length(a));
style_a=['bo';'r*';'gs';'md'];
style_b=[':b';':r';':g';':m'];
figure(1);
hold on;
for m=1:3
%     sum=zeros(1,length(a));
%     for j=1:m
%         sum=sum+nchoosek(2*m,m-j)*(-1)^j*sin(2*j*a)/j;
%     end
%     int(m,:)=(nchoosek(2*m,m)*a+sum)/(4^m);
%     for j=1:4096
%         int(m,j)=integral(@(x) power(sin(x),2*m),0,a(j));
%     end
%     sqnr(m,:)=10*log(3/(2^(2*m))*pi./int(m,:))/log(10);
   % plot(OSR,sqnr(m,:),style_a(m));
    sqnr_aprox(m,:)=(10*log(1.5)+20*log(2-1)+10*log(2*m+1)+10*(2*m+1)*log(OSR)-20*m*log(pi))/log(10);
    plot(OSR,sqnr_aprox(m,:),style_a(m,:));
end
    xlabel('OSR','FontSize',16);
    ylabel('SQNR','FontSize',16);
    set(gca,'fontsize',16);
    legend('k=1','k=2','k=3','k=4','location','north');
    hold off;