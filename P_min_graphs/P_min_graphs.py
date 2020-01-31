# -*- coding: utf-8 -*-
"""
Created on Fri Oct 18 14:06:18 2019

@author: benja

Code to test the onchain_dev equation
"""

import numpy as np
import matplotlib.pyplot as plt

a_p = 80 #proposal a_p in proposal tokens
y_s_q = 90 #a_p of status quo tokens sold for previous present period tokens in the previous auction.
y_dai = 110 #a_p of previous present period tokens bought for status quo tokens in the previous auction.
z_p = 70 #a_p of proposal tokens bought in current auction
z_dai = 180 #a_p of present period tokens sold in current auction

zero_m_price = z_dai/z_p * y_s_q/y_dai

print("Zero manipulation price:", zero_m_price, "\n", a_p/z_p)

#The following are technically inequalities.
alpha = 1000 
z_a_p = a_p / (1 + alpha)

y_a_p = alpha * z_a_p 


p_real_in_dai = (z_dai - z_a_p ) / z_p

dai_real_in_s_q = y_s_q / (y_dai + y_a_p)


proposal_real_price_sq_2 = p_real_in_dai * dai_real_in_s_q


print("a_p: {}, p_real_in_dai: {}, dai_real_in_s_q: {}, proposal_real_price_sq_2: {} \n".format(a_p, p_real_in_dai, dai_real_in_s_q, proposal_real_price_sq_2))


a_ps = np.arange(1,100,0.1)
z_a_ps = a_ps / (1 + alpha)
y_a_ps = alpha * z_a_ps


z_ps = np.arange(1,100)

z_dais = z_ps*(z_dai/z_p)


proposal_real_price_sq_2s = (y_s_q/z_p) * np.minimum( z_dai/ (a_ps + y_dai), (z_dai - a_ps) / y_dai)

#proposal_real_price_sq_2s = (z_dai - z_a_ps) / z_p * y_s_q / (y_dai + y_a_ps) #Varying the proposal amount. This is valid while the correct split is selected i.e. alpha.

proposal_real_price_sq_2s_2 = (y_s_q/z_ps) * np.minimum( z_dais/ (a_p + y_dai), (z_dais - a_p) / y_dai)



fig, ax = plt.subplots(figsize=(7,5))
ax.plot(a_ps, proposal_real_price_sq_2s)

ax.set_title('[$V_{n-1, \mathrm{gov}}^{\mathrm{sell}}$, $V_{n-1, \mathrm{dai}}^{\mathrm{sell}}$, $V_{n, \mathrm{gov}}^{\mathrm{buy}}$, $V_{n, \mathrm{dai}}^{\mathrm{buy}}$] = ' + str([y_s_q, y_dai, z_p, z_dai]) + ',\nHonest traders price gov$_{n-1}/$gov$_{n} =$ ' + '%s' % float('%.3g' % zero_m_price), fontsize='large')
ax.set_xlabel('$A_n$ [dai]', fontsize='large')
ax.set_ylabel('$P_{n, \mathrm{min}}$', fontsize='large')
ax.grid()

fig.savefig("increasing_An.pdf")

fig, bx = plt.subplots(figsize=(7,5))
bx.plot(z_dais, proposal_real_price_sq_2s_2)
#plt.figure(num=None, figsize=(80, 6), dpi=80, facecolor='w', edgecolor='k')

z_p_dai_price = z_dai/z_p

x_label = '$V_{n, \mathrm{dai}}^{\mathrm{buy}}$ [dai] while $V_{n, \mathrm{dai}}^{\mathrm{buy}}/V_{n, \mathrm{gov}}^{\mathrm{buy}} = $' + '%s' % float('%.3g' % z_p_dai_price)



bx.set_title('[$A_n$, $V_{n-1, \mathrm{gov}}^{\mathrm{sell}}$, $V_{n-1, \mathrm{dai}}^{\mathrm{sell}}$ = ' + str([a_p, y_s_q, y_dai]) + ',\nHonest traders price gov$_{n-1}/$gov$_{n} =$ ' + '%s' % float('%.3g' % zero_m_price), fontsize='large')
bx.set_xlabel(x_label, fontsize='large')
              #+ '%s' % float('%.1g' % z_p), fontsize='large')
bx.set_ylabel('$P_{n, \mathrm{min}}$', fontsize='large')
bx.grid()

fig.savefig("increasing_trade.pdf")

z_ps = np.arange(50,100)

z_dais = z_ps*(z_dai/z_p)

proposal_real_price_sq_2s_2 = (y_s_q/z_ps) * np.minimum( z_dais/ (a_p + y_dai), (z_dais - a_p) / y_dai)

fig, bx = plt.subplots(figsize=(7,5))
bx.plot(z_dais, proposal_real_price_sq_2s_2)







