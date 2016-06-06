function dst = p3d_nms1d(src, halfWnd, supVal)
% NON_MAX_SUP_1D -- non-maxima suppression on a 1D array
%	NON_MAX_SUP_1D(src, halfWnd, supVal) - Performs non-maxima suppresion
%	on the 1D array 'src', the suppression window size is 'halfWnd*2+1'.
%	result after suppresion is stored in 'dst'. All non-maxima values
%	are assigned 'supVal' in 'dst', the maximas in 'src' retain their
%	original values in 'dst'.
%
%	Complexity: O(N) where N is the length of the 1D src array, including
%	worst case.
%   When two or more same values occur in the same window, only the first
%   value is retained. i.e. if src = [0 1 2 2 1 0 0 2 1 2 1 0], halfWnd = 2
%   and supVal = -1, then result is: dst = [-1 -1 2 -1 -1 -1 -1 2 -1 -1 -1
%   -1]
%   If it is desired to retain a plateau, (eg. all of the 2's in 0 1 2 2 2
%   1 0) then one may do a second pass of the results to look specifically
%   for plateaus.
	
src = src(:);
dst = zeros(size(src));
len = size(src, 1);

dstCnt = 0;
srcCnt = 0;

maxInd = 1;
i = 1;
while(i <= len)
    if (maxInd < i - halfWnd)
        maxInd = i - halfWnd;
    end
    e = min(i + halfWnd, len);
    while(maxInd <= e)
        srcCnt = srcCnt + 1;
        if (src(maxInd) > src(i))
            break;
        else
            dstCnt = dstCnt + 1;
            dst(maxInd) = supVal;
        end
        maxInd = maxInd + 1;
    end
    if (maxInd > e) % src(i) is a maxima in the search window
        dstCnt = dstCnt + 1;
        dst(i) = src(i); % the loop above suppressed the maximum, so set it back
        maxInd = i+1;
        i = i + halfWnd;
    else
        dstCnt = dstCnt + 1;
        dst(i) = supVal;
    end
    
    i = i + 1;
end % while(i <= len)
        