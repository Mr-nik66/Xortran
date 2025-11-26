# XORTRAN

XORTRAN is a multilayer perceptron (MLP) neural network written in FORTRAN IV,
compiled and executed for both the IBM 1130 (1965) and the PDP-11 (1970~1980).

It learns the classic non-linear XOR problem using:

- A 4-neuron hidden layer with a leaky ReLU activation
- Backpropagation
- He-like initialization
- Learning rate annealing
- Sigmoid activation for the output layer

**IBM 1130 version**

For the IBM 1130, the code is written in
[IBM 1130 FORTRAN language](http://bitsavers.informatik.uni-stuttgart.de/pdf/ibm/1130/lang/C26-5933-3_1130_Fortran_Language_1965.pdf)
from 1965, the manual for which can be consulted online.

Training the network on the real hardware is expected to take probably around 30
minutes, however, this couldn’t be measured, as the only IBM 1130 available to
me is not fully operational. There is no throttling available in SIMH for the
IBM 1130, so the results are almost instantaneous.

The IBM 1130 version requires only 8K of memory, with DMS V2 using about 0.5K,
leaving 7.5K available for the neural network.

**PDP-11 version**

For the PDP-11, the code is written in Fortran 66 for the
[DEC FORTRAN IV compiler V20](https://bitsavers.org/www.computer.museum.uq.edu.au/RT-11/DEC-11-LRFPA-A-D%20RT-11%20FORTRAN%20Compiler%20and%20Object%20Time%20System%20User%27s%20Manual.pdf)
from 1974.

The default settings for SIMH use the original PDP-11/20 from 1970. Later, the
PDP-11/34A would have typically been used, as it was the smallest and most
affordable PDP-11 model equipped with an FP11 floating-point processor in the
late 1970s.

The training of the 17 parameters should take a couple minutes on a real
PDP-11/34A. In SIMH, setting the throttle to 200K (`set throttle 200K`) provides
a more realistic execution speed. The PDP-11 version requires at least 32
kilobytes of memory, most of it for RT-11.

### Output

After starting, the neural network is trained on the XOR problem. The output
shows the mean squared loss every 100 epochs along with the current learning
rate, gradually converging toward the expected XOR outputs.

The final predictions from the forward pass are then displayed.

Output for the IBM 1130:

```
EPOCH   1 LOSS 0.457087696297 LR 0.425000
EPOCH 100 LOSS 0.306881130556 LR 0.361249
EPOCH 200 LOSS 0.078406989778 LR 0.307062
EPOCH 300 LOSS 0.002172688028 LR 0.261002
EPOCH 400 LOSS 0.000745905681 LR 0.221852
EPOCH 500 LOSS 0.000411985442 LR 0.188574
 
 0 0 GOT 0.003497 EXPECTED 0.
 0 1 GOT 0.991684 EXPECTED 1.
 1 0 GOT 0.965385 EXPECTED 1.
 1 1 GOT 0.014040 EXPECTED 0.
```

## How to run

You will need SIMH for both the IBM 1130 and PDP-11 versions.

**IBM 1130**

- Start SIMH with `ibm1130 boot.ini` inside the IBM-1130 folder. Some
  distributions don't include it in the SIMH package, you will then need to
  build it from upstream sources.
- The `.ini` will automatically:
  - Boot DMS
  - Read the punched cards containing the FORTRAN source code and compilation
    jobs
  - Run XORTRAN

A log file from the compiler will appear in `out.lst` in the IBM-1130 folder

There is no speed throttling in the simulator. Actual execution speed would
probably last half an hour.

**PDP-11**

- Start SIMH with `pdp11 boot.ini` inside the folder.
- At the RT-11 prompt, which should just show a dot, type `XORTRN`. Training the
  network should take about 3mn to complete.

- To build from source:

```text
.FORTRAN/LIST:XORTRN.LST XORTRN.FOR
.LINK XORTRN.OBJ,FORLIB
.RUN XORTRN
```

The compiler will print a `XORTRN.LST` log file inside RT-11.

## Background

This project demonstrates that a stock FORTRAN IV environment from the 1960s and
1970s was sufficient to implement a basic neural network with backpropagation,
even with punch cards and 16K of core memory. It is both a retro-computing stunt
and a genuine "what-if" historical experiment.

Had XORTRAN existed in 1965, it would have significantly shifted the perception
of neural networks. At that time, training a multi-layer network was considered
largely theoretical, and neural networks were thought to be incapable of solving
non-linear problems.

A few dozen punched cards and a working demo on widely available machines could
have changed the narrative years before the AI winter set in. It might have kept
research funding alive, encouraged systematic exploration of hidden layers,
gradient descent variants, and activation functions, and perhaps even seeded
early industrial applications in pattern recognition and process control.

XORTRAN is therefore not just a curiosity, it is a tiny time-machine showing
that the hardware and software of 1965 were already sufficient for neural
networks. Only the ideas and a few hundred lines of Fortran were missing.

Enjoy the punch cards.

## Licence

© 2025 Damien Boureille

This code is released under the MIT License.\
You are free to use, copy, modify, and redistribute it, provided that you credit
the original author.
