function [ output ] = integrator( input,bits)
    output = zeros(1,input.size(2));
    output = fi(output,'Signedness','Unsigned','WordLength',55,'FractionLength',0,'RoundingMethod', 'Floor', 'OverflowAction', 'Wrap');
    
    output(1) = 0;
    for i=1:input.size(2)-1
        output(i+1)=output(i)+input(i);
    end
end

