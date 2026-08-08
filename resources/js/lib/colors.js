// JDC design system tokens (mirror resources/css/app.css)
// Charts (ApexCharts) need literal strings — these mirror the CSS custom properties.

export const jdcColors = {
  brand: {
    50: 'oklch(0.984 0.008 225.1)',
    100: 'oklch(0.970 0.016 221.1)',
    200: 'oklch(0.937 0.036 216.0)',
    300: 'oklch(0.880 0.067 217.7)',
    400: 'oklch(0.790 0.109 219.1)',
    500: 'oklch(0.706 0.144 232.4)',
    600: 'oklch(0.612 0.125 233.0)',
    700: 'oklch(0.532 0.107 231.9)',
    800: 'oklch(0.426 0.144 259.8)',
    900: 'oklch(0.366 0.121 259.8)',
  },
  gray: {
    50: 'oklch(0.984 0.003 247.858)',
    100: 'oklch(0.968 0.007 247.896)',
    200: 'oklch(0.929 0.013 255.508)',
    300: 'oklch(0.869 0.022 252.894)',
    400: 'oklch(0.704 0.040 256.788)',
    500: 'oklch(0.554 0.046 257.417)',
    600: 'oklch(0.446 0.043 257.281)',
    700: 'oklch(0.372 0.044 257.287)',
    800: 'oklch(0.279 0.041 260.031)',
    900: 'oklch(0.208 0.042 265.755)',
  },
  status: {
    pending: 'oklch(0.769 0.165 70.1)',        // warning
    confirmed: 'oklch(0.546 0.215 262.9)',     // info
    completed: 'oklch(0.627 0.170 149.2)',     // success
    cancelled: 'oklch(0.577 0.215 27.3)',      // error
    'no-show': 'oklch(0.577 0.215 27.3)',      // error (legacy alias)
  },
};
