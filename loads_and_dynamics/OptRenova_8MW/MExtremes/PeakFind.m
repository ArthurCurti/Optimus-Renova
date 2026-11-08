 function  TimeSer = PeakFind( TimeSer )
      % The logic in this routine was based upon the GPP Rainflow routine which
      % was based upon the RF routines in LIFE2.  Paul Veers was probably
      % responsible for the original logic.  There were bugs in the original
      % LIFE2 code, so we fixed them here.
      % This algorithm assumes a constant time step!     
 
 
      % Identify peaks and troughs in the time series.  The first and last points are considered peaks or troughs.
      % Sometimes the peaks can be flat for a while, so we have to deal with that nasty situation.
   
      %  TimeSer(numRecs,numChannels)
   
   NumPFCols = size(TimeSer,2);
%    NumRecs = size(TimeSer,1);
%    
%    for IC=1:NumPFCols
% 
%          % Initialize the algorithm.
% 
%       X2     = TimeSer(2,IC);
%       DX1    = X2 - TimeSer(1,IC);
%       DX_Old = DX1;
% %       count = 0;
%       for IR=3:NumRecs
% 
%          X1  = X2;
%          X2  = TimeSer(IR, IC);
%          DX2 = X2 - X1;
% 
%             % Check for a change in slope.
% 
%          if ( DX_Old*DX2 < 0 )  
% 
%                % Calculate the three-point parabolic interpolation.  Save delta.
% %                if(mod(count,20) == 0)
% %                   fprintf ('%d\n ',IR);
% %                else
% %                   fprintf ('%d ',IR);
% %                end
% %                count = count + 1;
%             TimeSer(IR-1,IC) = X1 - 0.125*( DX1 + DX2 )^2/( DX2 - DX1 );
%             DX_Old = DX2;
% 
%          end
% 
%             % Update delta.
% 
%          DX1 = DX2;
% 
%       end % for IR
% 
%    end % for IC
   
   for IC=1:NumPFCols
      data = TimeSer(:,IC);
      backdiff   = data(2:end-1) - data(1:end-2);
      forwdiff   = data(3:end) - data(2:end-1);
      signchange = sign(backdiff) + sign(forwdiff) ;
      peakInds   = find(signchange == 0) + 1;
      if (~isempty(peakInds))
         data(peakInds) = data(peakInds) - 0.125.*(backdiff(peakInds-1) + forwdiff(peakInds-1)).^2 ./ (forwdiff(peakInds-1) - backdiff(peakInds-1));
      end
      notFinite = ~isfinite(data);
      data(notFinite) = TimeSer(notFinite,IC);
      TimeSer(:,IC) = data;
   end
   
   
      %errVals = TimeSer(:,1) - data;
      %fprintf('Total error: %f6.1\n',sum(errVals));
     
%    for IC=1:NumPFCols
%    % Alternative function
%       t = TimeSer2(1:end-1,IC);
%       ts = TimeSer2(2:end,IC);
%       dx2 = ts - t;
%       
%    end
   
 end % function [ Peaks, NumPeaks ] = GetPeaks( TimeSer )
