function D = bin2decMat(B)
%  bin2decMat Convert binary array to decimal integer matrix.
%     D = bin2decMat(B) interprets the binary string B and returns in D the
%     equivalent decimal number.  
%  
%     Each row of B is interpreted as a binary number. 
%     
%     Example
%         bin2decMat([0 1 0 1 1 1]) returns 23
D = bin2dec(int2str(B));
end % end function