function [ output ] = sigma_delta_modulator(func,fclk,dt,time,R1,R2,C,Vth,Vhist)
    
    if (nargin<4)
        time = 10000e-6;        
        if (nargin<3)
           dt = 1/1000e6;
            if (nargin<2)
               fclk = 50e6;  
                if (nargin<1)
                   func = @(t) 3.3/2 + 3.3/2 *sin(2*pi*1000*t) + 0.1*randn(1,numel(t));
                end
            end
        end
    end
    
    var_type = whos('func');
    if (~strcmp (var_type.class,'function_handle'))
       fprintf('func debe ser una funciÃ³n\n'); 
       return;
    end
    
    
    %Vhist =0.0001;
    %wo =2*pi*20000;%2*pi*1e3;
    
   
    
    t = 0:dt:time;
    
    %s = 3.3* ones(1,numel(t));
    s = func(t);    
    clk = (square(2*pi*fclk*t) + 1)/2;
    edge = [0 (diff(clk)>0)];
    
    % H(s) = 1/s => H(z) = dt/2 * (1+Z^-1)/(1-Z^-1)
    % Y(t) = dt/2 * ( x(t) + x(t-1) ) + y(t-1)
    
    %  -- (+) -- x ->( H )-----> Y ------->( not Q ) --- Q -->|------->
    %      |<-------------------------------------------------|   
    
    
    
    y(1:3) = 0;
    q(1:2) = 0;
    %x(1:3) = 0;
    output(1:2) = 0;
    
    k1 = R2/(R1+R2);
    k2 = R1/(R1+R2);
    w0= (1/R1+1/R2)/C;
    a=2/dt-w0; %número mágico 1
    b=2/dt+w0; %número mágico 2
    for i=3:numel(t)
        
        aux= k1*(s(i)+s(i-1))+k2*(q(i-1)+q(i-2));
        y(i)= (w0*aux+a*y(i-1))/b;
        %y(i) = dt/wo *( s(i)+q(i-1)-2*y(i-1) ) + y(i-1);
        
        %aux= s(i-1)/R1+q(i-1)/R2-y(i-1)*k;
        %y(i) = aux*dt/C +y(i-1);
        
        %y(i) = (x(i)*wo+x(i-1)*wo-y(i-1)*(wo-2/dt))/(2/dt+wo);
        %y(i) = dt/2*(x(i-1) + x(i))+y(i-1);
        
        
        if (edge(i)==1)
            if (output(i-1) == 1)
                if (y(i) < Vth-Vhist) 
                   q(i) = 3.3;
                   output(i) = 0;
                else
                   q(i) = 0;
                   output(i) = 1;
                end
            else
                if (y(i) > Vth+Vhist)
                   q(i) = 0;
                   output(i) = 1;
                else
                   q(i) = 3.3;
                   output(i) = 0;
                end
            end
        else
            q(i) = q(i-1);
            output(i) = output(i-1);
        end
            
    end
    
%     a(1)= subplot(411);
%     plot(t,s);
%     title('Signal');
%     a(2)= subplot(412);
%     plot(t,y);
%     title('Filter Output');
%     a(3)= subplot(413);
%     stem(t,output);
%     title('Sigma Delta Output');
%     a(4)= subplot(414);
%     stem(t,edge);
%     title('Rising Clock Edge');
%         
%     linkaxes(a, 'x');    
%     
%     figure;
%      
%     plot(conv(output,ones(1,1000)));
    output = output (edge==1);
    
end
    
    
    
    
    
    
    
    
    

