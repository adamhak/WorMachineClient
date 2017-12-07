function [Head, Tail]=HTbyR1R2(R1,R2)
%Determine Head/Tail By R1 and R2 sizes

if R2>=0.9
    Head=R1;
    Tail=R2;
elseif R1>=0.9
    Head=R2;
    Tail=R1;
end

if R2<=0.6
    Head=R1;
    Tail=R2;
elseif R1<=0.6
    Head=R2;
    Tail=R1;
end

if R2>=0.9 && R1>=0.9
    if R1>R2
       Head=R2;
       Tail=R1;
    else
       Head=R1;
       Tail=R2;
    end
end

if R2<=0.6 && R1<=0.6
    if R1>R2
       Head=R1;
       Tail=R2;
    else
       Head=R2;
       Tail=R1;
    end
end

if R2<=0.9 && R2>=0.6 && R1>=0.6 && R1<=0.9
    if R1>R2
       Head=R1;
       Tail=R2;
    else
       Head=R2;
       Tail=R1;
    end
end