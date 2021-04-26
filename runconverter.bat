set projectName=jogo

taskkill /f /im %projectName%.exe

\masm32\bin\bldall %projectName%
%projectName%.exe