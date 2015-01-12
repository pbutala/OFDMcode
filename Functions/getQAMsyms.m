%% Syms = getQAMsyms(M) returns QAM symbols 
% getQAMsyms(M) plots QAM symbols on a scatterplot.
%
% This function returns normalized symbols for M-QAM where M is an integral
% exponent of 2. If no output variable specified, the function displays
% the constellation on a scatterplot.

%% HEADER -----------------------------------------------------------------
% Author: Pankil Butala
% Email: pbutala@bu.edu
% Institution: Multimedia Communications Laboratory,
%              Boston University.
% Generated: 14th February, 2013
%
% Disclaimer: The file is provided 'as-is' to the user. It has not been
% tested for any bugs or inconsistent behavior. If you have any questions
% or bugs to report, please email the author at the specified email address
%
% Copyright (C) Pankil Butala 2014
% Modifications: 
% 04/14/14: Added optional 'fEnergy' flag. If true, symbols are scaled to
% suffice unit energy on average (assume uniform symbol distribution). 
% Else symbols are scaled to get integral coefficients
% Default: fEnergy = false;
% 
% 10/14/14: Added optional 'fGray' flag. If true, QAM syms are arranged to
% reflect Gray code
% Default: fGray: true;
% 
% End Header --------------------------------------------------------------

function Syms = getQAMsyms(M,fEnergy,fGray)
bps = log2(M);      % bits per symbol
if ~exist('fEnergy','var')
    fEnergy = false;
end
if ~exist('fGray','var')
    fGray = true;
end
% Sanity check for integral exponent (bps must be integer)
if (rem(bps,1) ~= 0) || (M==0)  
    error('''M'' must be an integral exponent of 2');
end

bdX = ceil(bps/2);  % bits along dimention X
bdY = floor(bps/2); % bits along dimention Y

ncX = power(2,bdX); % #coefficients along dimension X
ncY = power(2,bdY); % #coefficients along dimension Y

cofX = (1-ncX)/2:1:(ncX-1)/2;   % coefficients along dimension X
cofY = (1-ncY)/2:1:(ncY-1)/2;   % coefficients along dimention Y

[ReC,ImC] = meshgrid(cofX,cofY);    % generate Real & Imag coefficients for all symbols
C = ReC + 1j*ImC;                   % generate all Complex Symbol matrix
Syms = C(:);                        % Vectorize the Symbol matrix
if(fEnergy)                     % if UNIT ENERGY
    Syms = Syms/sqrt((Syms'*Syms)/M);% Normalize symbols to have average energy = 1
else
    Syms = Syms*2;              % integral symbols
end
if(fGray)                       % if GRAY CODE
    symBits = getGrayBits(M);    % get gray coded bits for order 'M'
    symIdx = bin2decMat(symBits)+1; % convert bits to decimal index to rearrange symbols.
    for i=ncY+1:2*ncY:M         % flip every other row.
        symIdx(i:i+ncY-1) = symIdx(i+ncY-1:-1:i);
    end
    Syms(1:end) = Syms(symIdx);  % Arrange symbols to reflect M-ary Gray code.
end

if nargout == 0                 % if no output argument specified, display constellation
    Re = real(Syms);            % Scaled Real constellation values
    Im = imag(Syms);            % Scaled Imag constellation values
    uRe = unique(Re);           % Unique, sorted Scaled Real constellation values
    uIm = unique(Im);           % Unique, sorted Scaled Imag constellation values
    dRe = abs(uRe(1) - uRe(2)); % Distance between adjascent Re values
    dIm = abs(uIm(1) - uIm(2)); % Distance between adjascent Im values
    figure;                     % Generate axes for scatterplot
    scatter(Re,Im);             % Display the constellation on current axes
    set(gca,'XTick',uRe);       % Set X tick values to indicate Re coeffs
    set(gca,'YTick',uIm);       % Set Y tick values to indicate Im coeffs
    grid on;                    % Show the grid
    axis([uRe(1)-dRe uRe(end)+dRe uIm(1)-dIm uIm(end)+dIm]); % Scale axes for pleasant display
    axis equal;                 % Set axis aspect ratio = 1
    xlabel('Real');             % X axis shows Re constellation values
    ylabel('Imag');             % Y axis shoes Im constellation values
    tStr = sprintf('%d-QAM constellation diagram',M);   % Generate title
    title(tStr);                % Show title
    text(Re+dRe/10,Im+dIm/10,dec2bin(0:M-1)); 
end