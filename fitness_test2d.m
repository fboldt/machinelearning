function [fitness values]= fitness_test2d(vec,parameters)
%func = 'sin(5*pi*x).^6';
func = '2.^(-2*((x-0.1)/0.9).^2).*sin(5*pi*x).^6';
[x] = -1:0.001:1; vxp = x;
vzp = evaluate(func,x);
x = decode(vec);
fitness = evaluate(func,x); values=[x];
imprime(1,vxp,vzp,x,fitness,1,1); title(func);

function fitness = evaluate(func,x)
fitness = eval(func);

% Decodify bitstrings
function x = decode(v);
v = fliplr(v); s = size(v);
aux = 0:1:s(2)-1; aux = ones(s(1),1)*aux;
x1 = sum((v.*2.^aux)');
x = -1 + x1 .* (2 / (sum(ones(1,s(2)).*2.^(0:1:s(2)-1))));

% Print
function [] = imprime(PRINT,vx,vz,x,fx,it,mit);
if PRINT == 1,
   if rem(it,mit) == 0,
      plot(vx,vz); hold on; axis([-1 1 0 1]);
      xlabel('x'); ylabel('f(x)');
      plot(x,fx,'k*'); drawnow; hold off;
   end;
end;

