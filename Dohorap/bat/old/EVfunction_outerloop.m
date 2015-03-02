function T = EVfunction (ev1, ev2, ev3, X1, X2, X3, Y1, Y2, Y3, Z1, Z2, Z3)
    D = [ev1,0,0; 0,ev2,0; 0,0,ev3];
    V = [X1,Y1,Z1, X2,Y2,Z2, X3,Y3,Z3];
    T = V*D/V;
end