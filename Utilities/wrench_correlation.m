% Fine the correlation between two force signals
function corr_vec=wrench_correlation(R,L)
    % Get the number of columsn
    [r,c]=size(R);
    len=c-1; 
    % Neglect the time column
    corr_vec=zeros(len,1);
    for i=1:len
        % Compute the 0 lag correlation between both signals in a column
        % wise maner. 
        corr_vec(i)=xcorr(R(:,i+1),L(:,i+1),0,'coef')';
    end
end