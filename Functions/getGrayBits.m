%% BITS = getGrayBits(M) returns Gray coded bits for modulation order M

%% HEADER -----------------------------------------------------------------
% Author: Pankil Butala
% Email: pbutala@bu.edu
% Institution: Multimedia Communications Laboratory,
%              Boston University.
% Generated: 13th October, 2014
%
% Disclaimer: The file is provided 'as-is' to the user. It has not been
% tested for any bugs or inconsistent behavior. If you have any questions
% or bugs to report, please email the author at the specified email address
%
% Copyright (C) Pankil Butala 2014
% End Header --------------------------------------------------------------
function BITS = getGrayBits(M)
    bps = log2(M);
    BITS = zeros(M,bps);
    if bps>0
        BITS(1,end) = 0;
        BITS(2,end) = 1;
    end
    for i=1:bps-1
        R = power(2,i);
        BITS(R+1:2*R,end-i+1:end) = BITS(R:-1:1,end-i+1:end);
        BITS(R+1:2*R,end-i) = 1;
    end
end