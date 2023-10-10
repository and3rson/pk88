#!/usr/bin/env python3

import sys
import os


# Convert CHS to LBA
def chs2lba(c, h, s, hpc, spc):
    return (c * hpc + h) * spc + (s - 1)


# Convert LBA to CHS
def lba2chs(lba, hpc, spc):
    c = lba // (hpc * spc)
    h = (lba // spc) % hpc
    s = (lba % spc) + 1
    return c, h, s


chs = (522, 2, 5)
lba = chs2lba(*chs, 6, 17)  # 1058
print(lba)
assert chs == lba2chs(lba, 6, 17)

chs = (615 - 1, 6 - 1, 17)  # Last sector
lba = chs2lba(*chs, 6, 17)  # 65729
print(lba)
assert lba == 615 * 6 * 17 - 1  # Sector index = total sectors - 1
assert chs == lba2chs(lba, 6, 17)
