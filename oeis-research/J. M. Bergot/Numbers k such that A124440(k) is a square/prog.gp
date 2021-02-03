
\\ Numbers k such that A124440(k) is a square.
\\ https://oeis.org/A341032

A066840(n) = {my(h=n\2, d, b, r=0); f=factor(n)[, 1]; for(i=0, 2^#f - 1, b=binary(i); d=#f-#b; p=prod(j=1, #b, f[j+#f-#b]^b[j]); r += (-1)^vecsum(b) * p * binomial(1+h\p, 2)); r} \\ David A. Corneth, Apr 14 2015
A124440(n) = if(n>2, eulerphi(n)*n/2 - A066840(n), 1);
for(k=1, 10^10, if(issquare(A124440(k)), print1(k, ", ")));
