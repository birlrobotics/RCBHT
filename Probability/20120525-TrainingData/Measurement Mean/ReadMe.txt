These files contain the necessary conditions to assess whether the HLBs:
Rotation, Snap, and Mating have taken place.

The matrices contained here are diagonal (sparse) diagonal matrices.

For all matrices, the rows constitute the force axis:

Fx
Fy
Fz
Mx
My
Mz

The columns contains the LLBs that are key to yielding the desired HLBs. The conditions for different HLBs are different. 

Conditions desired for:

<< ROTATION >>
FX NA FX NA FX NA

<< SNAP >>
CT U(AL,FX) Fx U(AL,FX)	CT U(AL,FX)

<< MATING >>
FX FX FX FX FX FX



Where, U(Al,FX) is the union of AL and FX

