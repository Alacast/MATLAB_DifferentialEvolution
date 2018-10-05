function t = smh_roundDec(x,n)
% rounds a number x to the nth decimal place, then converts to string
% useful for displaying values
ten = 10^n;
x = 1/ten * round(x*ten);  
t = num2str(x);

% fill trailing 0s
decimalAt = strfind(t,'.');
while length(t) - decimalAt < n
  t = [t,'0'];
end

end