%% function [tDatV] = decodeOFDMsignal(signal,varargin)
% This extracts data from an ACOOFDM or DCOOFDM or DMT signal. To generate
% real valued time domain signals, DMT is the same as DCO with 0 offset.
% 
% 1. Signal: The ACO/DCO/DMT signal received
%
% TODO: support for carrier prefix
%
% VARIABLE INPUT ARGUMENTS: Listed below are optional input arguments that
% can be specified to modify the behaviour of the function.
% 
% 1. OFDMTYPE: Specifies ACOOFDM or DCOOFDM or DMT
%  default: OFDMTYPE = DCOOFDM
% 
% 2. N: Specifies number of subcarriers for each OFDM symbol
%  default: N=64
% 
% 3. Symbols: Specifies symbols associated with data for each subcarrier
% 
% 4. SCALE: Specifies scale factor for time domain signal generated
%  default: SCALE = 1
% 
% 5. FILETYPE: Specifies the type of file to save time domain signal to.
% Accepted values are 'TEXT' or 'MAT'. If 'TEXT' is specified, the time
% domain signal is saved to a *.txt file. If 'MAT' is specified, the time
% domain signal is saved to a *.mat file that can be loaded again in
% MATLAB.
%  default: FILETYPE = 'TEXT'
% 
% 6. FILENAME: Specifies the name/path of the file to save time domain
% signal to.
%  default: FILENAME = 'signal.txt'
% 
% NOTE: If any one of FILETYPE OR FILENAME are specified, the function will
% always save the time domain signal to the file.
%
% NOTE: If both, FILETYPE AND FILENAME, are NOT specified, the function
% will save the time domain signal to file ONLY if zero (0) output
% arguments are expected to be returned.
%
% 7. SHOWRCV: Specifies the flag to show received symbols (true/false)
%   default: false
% 8. SHOWRCVAX: Specifies the axes to show received symbols on
%   default: new figure
%
% OUTPUTS: 
% 1. TDATV: Data recovered from the signal.

%% HEADER -----------------------------------------------------------------
% Author: Pankil Butala
% Email: pbutala@bu.edu 
% Institution: Multimedia Communications Laboratory,
%              Boston University.
% Generated: 15th August, 2013
% 
% Modifications:
% 04/14/14: Added support to show constellation symbols
%
% Disclaimer: The file is provided 'as-is' to the user. It has not been
% tested for any bugs or inconsistent behavior. If you have any questions
% or bugs to report, please email the author at the specified email address
%
% Copyright (C) Pankil Butala 2013
% End Header --------------------------------------------------------------

function [tDatV] = decodeOFDMsignal(signal,varargin)

%% default initialization 
%(DO NOT MODIFY) Any changes in default behavior must be addressed using
%the variable input arguments.
ofdmType = 'DCOOFDM';       % default OFDM type
N = 64;                      % default # subcarriers
M = 64;                      % default # QAM symbols per subcarrier
SymSC = getQAMsyms(M);      % default constellation
fileType = 'text';          % default file type to save recovered data to
fileName = 'rcvdata.txt';    % default file to save time domain signal to
scale = 1;                    % default scale for time domain signal
fShowRcv = false;         % default flag for showing constellations generated by data
% end default initialization-----------------------------------------------

%% Read input parameters, if specified
if isvector(signal)
    sigLen = numel(signal);
else
    error('''signal'' must be a vector.');
end
            
nVArg = nargin-1;
if (rem(nVArg,2)~= 0)
    error('Check input arguments');
end
ArgName = 1;
ArgParam = ArgName + 1;
while(ArgName < nVArg)
    switch lower(varargin{ArgName})
        case 'ofdmtype'
            ofdmType = varargin{ArgParam};
        case 'n'
            N = varargin{ArgParam};
        case 'symbols'
            SymSC = varargin{ArgParam};
            if isvector(SymSC)
                M = numel(SymSC);
            else
                error('''Symbols'' must be a vector');
            end
            if (rem(log2(M),1) ~= 0)||(M==0)
                warning('Number of symbols is not an integral exponent of 2');
            end
        case 'scale'
            scale = varargin{ArgParam};
        case 'filetype'
            fileType = varargin{ArgParam};
            switch lower(fileType)
                case {'text','mat'}
                    %do nothing
                otherwise
                    error('File type must be ''TEXT'' or ''MAT''');
            end
            fSave = true;
        case 'filename'
            fileName = varargin{ArgParam};
            fSave = true;
        case 'showrcv'
            bflg = varargin{ArgParam};
            if isa(bflg,'logical')
                fShowRcv = bflg;
            else
                error('ShowConst must be logical');
            end
        case 'showrcvax'
            showrcvax = varargin{ArgParam};
        otherwise
            error('unknown parameter %s specified',varargin{ArgName});
    end
    ArgName = ArgName + 2;
    ArgParam = ArgName + 1;
end

%% Calculate number of data bearing carriers for specified ofdm type
switch lower(ofdmType)
    case 'acoofdm'
        fHop = 2;
    case {'dcoofdm','dmt'}
        fHop = 1;
    otherwise
        error('OFDM type must be ''ACOOFDM'' or ''DCOOFDM''');
end

%% Generate constellation
% SymSC = zeros(M+1,1);       % M+1st constellation point is set to 0 to assign it to padded data
% SymSC(1:M) = getQAMsyms(M); % Get subcarrier symbols

%% Recover time domain signal
signal(signal < 0) = 0;     % clip all signal values smaller than 0
signal  = signal./scale;    % unscale the signal values
Nfrm = ceil(sigLen/N);    % calculate number of ofdm frames (TODO: include carrier prefix)
tSigV = zeros(N*Nfrm,1);  % if signal length is not an integral multiple of N, make it so
tSigV(1:sigLen) = signal;   % pad signal to make its length an integral multiple of N
tSigM = reshape(tSigV,N,Nfrm);    % ccreate a matrix buffer to store symbols
% if ACO
% invert, shift and add
if strcmpi(ofdmType,'acoofdm')
    tSigMi = -tSigM;
    tSigM(1:N/2,:) = tSigM(1:N/2,:) + tSigMi(N/2+1:end,:);
    tSigM(N/2+1:end,:) = tSigM(N/2+1:end,:) + tSigMi(1:N/2,:);
end
%% Convert to frequency domain
fSigM = fft(tSigM,N,1)/sqrt(N); % FFT to recover freq domain signal

%% Extract data symbols
symDat = fSigM(2:fHop:N/2,:);

%% NN decode
symDist = abs(repmat(symDat(:),1,M) - repmat(SymSC(1:M).',numel(symDat),1));
[~,tDatV] = min(symDist,[],2);

%% show received symbols
if fShowRcv
    if exist('showrcvax','var')
        axes(showrcvax);        % set current axes for scatterplot
    else
        figure;                 % Generate axes for scatterplot
    end
    % plot received symbols
    Re = real(symDat);          % Get real parts of received symbols
    Im = imag(symDat);          % Get imag parts of received symbols
    scatter(Re,Im,72,'ro');             % Display the constellation on current axes
    % plot constellation symbols
    Re = real(SymSC);          % Get real parts of received symbols
    Im = imag(SymSC);          % Get imag parts of received symbols
    uRe = unique(Re);           % Unique, sorted Scaled Real constellation values
    uIm = unique(Im);           % Unique, sorted Scaled Imag constellation values
    dRe = abs(uRe(1) - uRe(2)); % Distance between adjascent Re values
    dIm = abs(uIm(1) - uIm(2)); % Distance between adjascent Im values
    set(gca,'XTick',uRe);       % Set X tick values to indicate Re coeffs
    set(gca,'YTick',uIm);       % Set Y tick values to indicate Im coeffs
    grid on;                    % Show the grid
    axis([uRe(1)-dRe uRe(end)+dRe uIm(1)-dIm uIm(end)+dIm]); % Scale axes for pleasant display
%     axis equal;                 % Set axis aspect ratio = 1
    xlabel('Real');             % X axis shows Re constellation values
    ylabel('Imag');             % Y axis shoes Im constellation values
%     tStr = sprintf('%d-QAM constellation diagram',M);   % Generate title
%     title(tStr);                % Show title
    hold on;
    scatter(Re,Im,72,'bx');     % Display the constellation on current axes
    hold off;
end

%% Save data to file
% if save option NOT specified, save to file ONLY if time domain signal is
% NOT returned to caller
if ~exist('fSave','var')
    fSave = (nargout == 0);
end
if fSave
    switch lower(fileType)
        case 'text'
            fid = fopen(fileName,'w');  % open file to write to
            if fid~= -1
                fprintf(fid,'%f\r\n',tDatV);
                fclose(fid);
            else
                error('Error opening ''%s'' file.\n',fileName);
            end
        case 'mat'
            save filePath tDatV;        % save to signal file
        otherwise
            error('File type must be ''TEXT'' or ''MAT''');
    end
end
end % end decodeOFDMsignal