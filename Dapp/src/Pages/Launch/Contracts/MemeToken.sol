// SPDX-License-Identifier: MIT

// File: MemeToken.sol




pragma solidity ^0.8.0;

interface IERC20 {
	event Transfer(address indexed from, address indexed to, uint256 value);

	event Approval(address indexed owner, address indexed spender, uint256 value);
	// SPDX-License-Identifier: MIT


	pragma solidity ^0.8.0;

	interface IERC20 {
		event Transfer(address indexed from, address indexed to, uint256 value);

		event Approval(address indexed owner, address indexed spender, uint256 value);

		function totalSupply() external view returns (uint256);

		function balanceOf(address account) external view returns (uint256);

		function transfer(address to, uint256 amount) external returns (bool);

		function allowance(address owner, address spender) external view returns (uint256);

		function approve(address spender, uint256 amount) external returns (bool);

		function transferFrom(address from, address to, uint256 amount) external returns (bool);
	}

	interface IERC20Metadata is IERC20 {
		function name() external view returns (string memory);

		function symbol() external view returns (string memory);

		function decimals() external view returns (uint8);
	}

	abstract contract Context {
		function _msgSender() internal view virtual returns (address) {
			return msg.sender;
		}

		function _msgData() internal view virtual returns (bytes calldata) {
			return msg.data;
		}
	}

	contract ERC20 is Context, IERC20, IERC20Metadata {
		mapping(address => uint256) private _balances;

		mapping(address => mapping(address => uint256)) private _allowances;

		uint256 private _totalSupply;

		string private _name;
		string private _symbol;

		constructor(string memory name_, string memory symbol_) {
			_name = name_;
			_symbol = symbol_;
		}

		function name() public view virtual override returns (string memory) {
			return _name;
		}

		function symbol() public view virtual override returns (string memory) {
			return _symbol;
		}

		function decimals() public view virtual override returns (uint8) {
			return 18;
		}

		function totalSupply() public view virtual override returns (uint256) {
			return _totalSupply;
		}

		function balanceOf(address account) public view virtual override returns (uint256) {
			return _balances[account];
		}

		function transfer(address to, uint256 amount) public virtual override returns (bool) {
			address owner = _msgSender();
			_transfer(owner, to, amount);
			return true;
		}

		function allowance(
			address owner,
			address spender
		) public view virtual override returns (uint256) {
			return _allowances[owner][spender];
		}

		function approve(address spender, uint256 amount) public virtual override returns (bool) {
			address owner = _msgSender();
			_approve(owner, spender, amount);
			return true;
		}

		function transferFrom(
			address from,
			address to,
			uint256 amount
		) public virtual override returns (bool) {
			address spender = _msgSender();
			_spendAllowance(from, spender, amount);
			_transfer(from, to, amount);
			return true;
		}

		function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
			address owner = _msgSender();
			_approve(owner, spender, allowance(owner, spender) + addedValue);
			return true;
		}

		function decreaseAllowance(
			address spender,
			uint256 subtractedValue
		) public virtual returns (bool) {
			address owner = _msgSender();
			uint256 currentAllowance = allowance(owner, spender);
			require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
			unchecked {
				_approve(owner, spender, currentAllowance - subtractedValue);
			}

			return true;
		}

		function _transfer(address from, address to, uint256 amount) internal virtual {
			require(from != address(0), "ERC20: transfer from the zero address");
			require(to != address(0), "ERC20: transfer to the zero address");

			_beforeTokenTransfer(from, to, amount);

			uint256 fromBalance = _balances[from];
			require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
			unchecked {
				_balances[from] = fromBalance - amount;
				// Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
				// decrementing then incrementing.
				_balances[to] += amount;
			}

			emit Transfer(from, to, amount);

			_afterTokenTransfer(from, to, amount);
		}

		function _mint(address account, uint256 amount) internal virtual {
			require(account != address(0), "ERC20: mint to the zero address");

			_beforeTokenTransfer(address(0), account, amount);

			_totalSupply += amount;
			unchecked {
				// Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
				_balances[account] += amount;
			}
			emit Transfer(address(0), account, amount);

			_afterTokenTransfer(address(0), account, amount);
		}

		function _burn(address account, uint256 amount) internal virtual {
			require(account != address(0), "ERC20: burn from the zero address");

			_beforeTokenTransfer(account, address(0), amount);

			uint256 accountBalance = _balances[account];
			require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
			unchecked {
				_balances[account] = accountBalance - amount;
				// Overflow not possible: amount <= accountBalance <= totalSupply.
				_totalSupply -= amount;
			}

			emit Transfer(account, address(0), amount);

			_afterTokenTransfer(account, address(0), amount);
		}

		function _approve(address owner, address spender, uint256 amount) internal virtual {
			require(owner != address(0), "ERC20: approve from the zero address");
			require(spender != address(0), "ERC20: approve to the zero address");

			_allowances[owner][spender] = amount;
			emit Approval(owner, spender, amount);
		}

		function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
			uint256 currentAllowance = allowance(owner, spender);
			if (currentAllowance != type(uint256).max) {
				require(currentAllowance >= amount, "ERC20: insufficient allowance");
				unchecked {
					_approve(owner, spender, currentAllowance - amount);
				}
			}
		}

		function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

		function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
	}

	interface IUniswapV2Factory {
		event PairCreated(address indexed token0, address indexed token1, address pair, uint);

		function feeTo() external view returns (address);

		function feeToSetter() external view returns (address);

		function getPair(address tokenA, address tokenB) external view returns (address pair);

		function allPairs(uint) external view returns (address pair);

		function allPairsLength() external view returns (uint);

		function createPair(address tokenA, address tokenB) external returns (address pair);

		function setFeeTo(address) external;

		function setFeeToSetter(address) external;
	}

	interface IUniswapV2Router01 {
		function factory() external pure returns (address);

		function WETH() external pure returns (address);

		function addLiquidity(
			address tokenA,
			address tokenB,
			uint amountADesired,
			uint amountBDesired,
			uint amountAMin,
			uint amountBMin,
			address to,
			uint deadline
		) external returns (uint amountA, uint amountB, uint liquidity);

		function addLiquidityETH(
			address token,
			uint amountTokenDesired,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline
		) external payable returns (uint amountToken, uint amountETH, uint liquidity);

		function removeLiquidity(
			address tokenA,
			address tokenB,
			uint liquidity,
			uint amountAMin,
			uint amountBMin,
			address to,
			uint deadline
		) external returns (uint amountA, uint amountB);

		function removeLiquidityETH(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline
		) external returns (uint amountToken, uint amountETH);

		function removeLiquidityWithPermit(
			address tokenA,
			address tokenB,
			uint liquidity,
			uint amountAMin,
			uint amountBMin,
			address to,
			uint deadline,
			bool approveMax,
			uint8 v,
			bytes32 r,
			bytes32 s
		) external returns (uint amountA, uint amountB);

		function removeLiquidityETHWithPermit(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline,
			bool approveMax,
			uint8 v,
			bytes32 r,
			bytes32 s
		) external returns (uint amountToken, uint amountETH);

		function swapExactTokensForTokens(
			uint amountIn,
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external returns (uint[] memory amounts);

		function swapTokensForExactTokens(
			uint amountOut,
			uint amountInMax,
			address[] calldata path,
			address to,
			uint deadline
		) external returns (uint[] memory amounts);

		function swapExactETHForTokens(
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external payable returns (uint[] memory amounts);

		function swapTokensForExactETH(
			uint amountOut,
			uint amountInMax,
			address[] calldata path,
			address to,
			uint deadline
		) external returns (uint[] memory amounts);

		function swapExactTokensForETH(
			uint amountIn,
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external returns (uint[] memory amounts);

		function swapETHForExactTokens(
			uint amountOut,
			address[] calldata path,
			address to,
			uint deadline
		) external payable returns (uint[] memory amounts);

		function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

		function getAmountOut(
			uint amountIn,
			uint reserveIn,
			uint reserveOut
		) external pure returns (uint amountOut);

		function getAmountIn(
			uint amountOut,
			uint reserveIn,
			uint reserveOut
		) external pure returns (uint amountIn);

		function getAmountsOut(
			uint amountIn,
			address[] calldata path
		) external view returns (uint[] memory amounts);

		function getAmountsIn(
			uint amountOut,
			address[] calldata path
		) external view returns (uint[] memory amounts);
	}

	interface IUniswapV2Router02 is IUniswapV2Router01 {
		function removeLiquidityETHSupportingFeeOnTransferTokens(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline
		) external returns (uint amountETH);

		function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline,
			bool approveMax,
			uint8 v,
			bytes32 r,
			bytes32 s
		) external returns (uint amountETH);

		function swapExactTokensForTokensSupportingFeeOnTransferTokens(
			uint amountIn,
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external;

		function swapExactETHForTokensSupportingFeeOnTransferTokens(
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external payable;

		function swapExactTokensForETHSupportingFeeOnTransferTokens(
			uint amountIn,
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external;
	}

	abstract contract Ownable is Context {
		address private _owner;

		event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

		constructor() {
			_transferOwnership(_msgSender());
		}

		modifier onlyOwner() {
			_checkOwner();
			_;
		}

		function owner() public view virtual returns (address) {
			return _owner;
		}

		function _checkOwner() internal view virtual {
			require(owner() == _msgSender(), "Ownable: caller is not the owner");
		}

		function renounceOwnership() public virtual onlyOwner {
			_transferOwnership(address(0));
		}

		function transferOwnership(address newOwner) public virtual onlyOwner {
			require(newOwner != address(0), "Ownable: new owner is the zero address");
			_transferOwnership(newOwner);
		}

		function _transferOwnership(address newOwner) internal virtual {
			address oldOwner = _owner;
			_owner = newOwner;
			emit OwnershipTransferred(oldOwner, newOwner);
		}
	}

	contract TestMemeTaxedToken is ERC20, Ownable {
	    uint256 public buyTax;
	    uint256 public sellTax;
	    uint256 public transferTax;

	    address public taxRecipient;
	    address public treasuryAddress;

	    uint256 private constant FIXED_TREASURY_TAX = 5; // 0.5% (5 / 1000)

	    enum TransactionType { BUY, SELL, TRANSFER }

	    constructor(
	        string memory name,
	        string memory symbol,
	        uint256 initialSupply,
	        uint256 _buyTax,
	        uint256 _sellTax,
	        uint256 _transferTax,
	        address _taxRecipient,
	        address _treasuryAddress
	    ) ERC20(name, symbol) {
	        require(_buyTax <= 100 && _sellTax <= 100 && _transferTax <= 100, "Tax must be less than or equal to 100");

	        buyTax = _buyTax;
	        sellTax = _sellTax;
	        transferTax = _transferTax;
	        taxRecipient = _taxRecipient;
	        treasuryAddress = _treasuryAddress;

	        // Mint the initial supply to the caller
	        _mint(msg.sender, initialSupply * 10 ** decimals());

	        // Transfer ownership to the caller
	        transferOwnership(msg.sender);
	    }

	    function setTaxRates(uint256 _buyTax, uint256 _sellTax, uint256 _transferTax) external onlyOwner {
	        require(_buyTax <= 100 && _sellTax <= 100 && _transferTax <= 100, "Tax must be less than or equal to 100");
	        buyTax = _buyTax;
	        sellTax = _sellTax;
	        transferTax = _transferTax;
	    }


	    function _transfer(
	        address sender,
	        address recipient,
	        uint256 amount
	    ) internal virtual override {
	        uint256 taxAmount;
	        if (sender == owner()) {
	            // Exclude owner from buy tax
	            taxAmount = (amount * buyTax) / 100;
	        } else if (recipient == owner()) {
	            // Exclude owner from sell tax
	            taxAmount = (amount * sellTax) / 100;
	        } else {
	            taxAmount = (amount * transferTax) / 100;
	        }
	        uint256 treasuryTaxAmount = (amount * FIXED_TREASURY_TAX) / 1000;
	        uint256 transferAmount = amount - taxAmount - treasuryTaxAmount;

	        super._transfer(sender, taxRecipient, taxAmount);
	        super._transfer(sender, treasuryAddress, treasuryTaxAmount);
	        super._transfer(sender, recipient, transferAmount);
	    }
	}

	function totalSupply() external view returns (uint256);

	function balanceOf(address account) external view returns (uint256);

	function transfer(address to, uint256 amount) external returns (bool);

	function allowance(address owner, address spender) external view returns (uint256);

	function approve(address spender, uint256 amount) external returns (bool);

	function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC20Metadata is IERC20 {
	function name() external view returns (string memory);

	function symbol() external view returns (string memory);

	function decimals() external view returns (uint8);
}

abstract contract Context {
	function _msgSender() internal view virtual returns (address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes calldata) {
		return msg.data;
	}
}

contract ERC20 is Context, IERC20, IERC20Metadata {
	mapping(address => uint256) private _balances;

	mapping(address => mapping(address => uint256)) private _allowances;

	uint256 private _totalSupply;

	string private _name;
	string private _symbol;

	constructor(string memory name_, string memory symbol_) {
		_name = name_;
		_symbol = symbol_;
	}

	function name() public view virtual override returns (string memory) {
		return _name;
	}

	function symbol() public view virtual override returns (string memory) {
		return _symbol;
	}

	function decimals() public view virtual override returns (uint8) {
		return 18;
	}

	function totalSupply() public view virtual override returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) public view virtual override returns (uint256) {
		return _balances[account];
	}

	function transfer(address to, uint256 amount) public virtual override returns (bool) {
		address owner = _msgSender();
		_transfer(owner, to, amount);
		return true;
	}

	function allowance(
		address owner,
		address spender
	) public view virtual override returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) public virtual override returns (bool) {
		address owner = _msgSender();
		_approve(owner, spender, amount);
		return true;
	}

	function transferFrom(
		address from,
		address to,
		uint256 amount
	) public virtual override returns (bool) {
		address spender = _msgSender();
		_spendAllowance(from, spender, amount);
		_transfer(from, to, amount);
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
		address owner = _msgSender();
		_approve(owner, spender, allowance(owner, spender) + addedValue);
		return true;
	}

	function decreaseAllowance(
		address spender,
		uint256 subtractedValue
	) public virtual returns (bool) {
		address owner = _msgSender();
		uint256 currentAllowance = allowance(owner, spender);
		require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
		unchecked {
			_approve(owner, spender, currentAllowance - subtractedValue);
		}

		return true;
	}

	function _transfer(address from, address to, uint256 amount) internal virtual {
		require(from != address(0), "ERC20: transfer from the zero address");
		require(to != address(0), "ERC20: transfer to the zero address");

		_beforeTokenTransfer(from, to, amount);

		uint256 fromBalance = _balances[from];
		require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
		unchecked {
			_balances[from] = fromBalance - amount;
			// Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
			// decrementing then incrementing.
			_balances[to] += amount;
		}

		emit Transfer(from, to, amount);

		_afterTokenTransfer(from, to, amount);
	}

	function _mint(address account, uint256 amount) internal virtual {
		require(account != address(0), "ERC20: mint to the zero address");

		_beforeTokenTransfer(address(0), account, amount);

		_totalSupply += amount;
		unchecked {
			// Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
			_balances[account] += amount;
		}
		emit Transfer(address(0), account, amount);

		_afterTokenTransfer(address(0), account, amount);
	}

	function _burn(address account, uint256 amount) internal virtual {
		require(account != address(0), "ERC20: burn from the zero address");

		_beforeTokenTransfer(account, address(0), amount);

		uint256 accountBalance = _balances[account];
		require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
		unchecked {
			_balances[account] = accountBalance - amount;
			// Overflow not possible: amount <= accountBalance <= totalSupply.
			_totalSupply -= amount;
		}

		emit Transfer(account, address(0), amount);

		_afterTokenTransfer(account, address(0), amount);
	}

	function _approve(address owner, address spender, uint256 amount) internal virtual {
		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
		uint256 currentAllowance = allowance(owner, spender);
		if (currentAllowance != type(uint256).max) {
			require(currentAllowance >= amount, "ERC20: insufficient allowance");
			unchecked {
				_approve(owner, spender, currentAllowance - amount);
			}
		}
	}

	function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

	function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}

interface IUniswapV2Factory {
	event PairCreated(address indexed token0, address indexed token1, address pair, uint);

	function feeTo() external view returns (address);

	function feeToSetter() external view returns (address);

	function getPair(address tokenA, address tokenB) external view returns (address pair);

	function allPairs(uint) external view returns (address pair);

	function allPairsLength() external view returns (uint);

	function createPair(address tokenA, address tokenB) external returns (address pair);

	function setFeeTo(address) external;

	function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
	function factory() external pure returns (address);

	function WETH() external pure returns (address);

	function addLiquidity(
		address tokenA,
		address tokenB,
		uint amountADesired,
		uint amountBDesired,
		uint amountAMin,
		uint amountBMin,
		address to,
		uint deadline
	) external returns (uint amountA, uint amountB, uint liquidity);

	function addLiquidityETH(
		address token,
		uint amountTokenDesired,
		uint amountTokenMin,
		uint amountETHMin,
		address to,
		uint deadline
	) external payable returns (uint amountToken, uint amountETH, uint liquidity);

	function removeLiquidity(
		address tokenA,
		address tokenB,
		uint liquidity,
		uint amountAMin,
		uint amountBMin,
		address to,
		uint deadline
	) external returns (uint amountA, uint amountB);

	function removeLiquidityETH(
		address token,
		uint liquidity,
		uint amountTokenMin,
		uint amountETHMin,
		address to,
		uint deadline
	) external returns (uint amountToken, uint amountETH);

	function removeLiquidityWithPermit(
		address tokenA,
		address tokenB,
		uint liquidity,
		uint amountAMin,
		uint amountBMin,
		address to,
		uint deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint amountA, uint amountB);

	function removeLiquidityETHWithPermit(
		address token,
		uint liquidity,
		uint amountTokenMin,
		uint amountETHMin,
		address to,
		uint deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint amountToken, uint amountETH);

	function swapExactTokensForTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external returns (uint[] memory amounts);

	function swapTokensForExactTokens(
		uint amountOut,
		uint amountInMax,
		address[] calldata path,
		address to,
		uint deadline
	) external returns (uint[] memory amounts);

	function swapExactETHForTokens(
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external payable returns (uint[] memory amounts);

	function swapTokensForExactETH(
		uint amountOut,
		uint amountInMax,
		address[] calldata path,
		address to,
		uint deadline
	) external returns (uint[] memory amounts);

	function swapExactTokensForETH(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external returns (uint[] memory amounts);

	function swapETHForExactTokens(
		uint amountOut,
		address[] calldata path,
		address to,
		uint deadline
	) external payable returns (uint[] memory amounts);

	function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

	function getAmountOut(
		uint amountIn,
		uint reserveIn,
		uint reserveOut
	) external pure returns (uint amountOut);

	function getAmountIn(
		uint amountOut,
		uint reserveIn,
		uint reserveOut
	) external pure returns (uint amountIn);

	function getAmountsOut(
		uint amountIn,
		address[] calldata path
	) external view returns (uint[] memory amounts);

	function getAmountsIn(
		uint amountOut,
		address[] calldata path
	) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
	function removeLiquidityETHSupportingFeeOnTransferTokens(
		address token,
		uint liquidity,
		uint amountTokenMin,
		uint amountETHMin,
		address to,
		uint deadline
	) external returns (uint amountETH);

	function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
		address token,
		uint liquidity,
		uint amountTokenMin,
		uint amountETHMin,
		address to,
		uint deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns (uint amountETH);

	function swapExactTokensForTokensSupportingFeeOnTransferTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external;

	function swapExactETHForTokensSupportingFeeOnTransferTokens(
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external payable;

	function swapExactTokensForETHSupportingFeeOnTransferTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external;
}

abstract contract Ownable is Context {
	address private _owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor() {
		_transferOwnership(_msgSender());
	}

	modifier onlyOwner() {
		_checkOwner();
		_;
	}

	function owner() public view virtual returns (address) {
		return _owner;
	}

	function _checkOwner() internal view virtual {
		require(owner() == _msgSender(), "Ownable: caller is not the owner");
	}

	function renounceOwnership() public virtual onlyOwner {
		_transferOwnership(address(0));
	}

	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		_transferOwnership(newOwner);
	}

	function _transferOwnership(address newOwner) internal virtual {
		address oldOwner = _owner;
		_owner = newOwner;
		emit OwnershipTransferred(oldOwner, newOwner);
	}
}

contract TestMemeTaxedToken is ERC20, Ownable {
    uint256 public buyTax;
    uint256 public sellTax;
    uint256 public transferTax;

    address public taxRecipient;
    address public treasuryAddress;

    uint256 private constant FIXED_TREASURY_TAX = 5; // 0.5% (5 / 1000)

    enum TransactionType { BUY, SELL, TRANSFER }

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint256 _buyTax,
        uint256 _sellTax,
        uint256 _transferTax,
        address _taxRecipient,
        address _treasuryAddress
    ) ERC20(name, symbol) {
        require(_buyTax <= 100 && _sellTax <= 100 && _transferTax <= 100, "Tax must be less than or equal to 100");

        buyTax = _buyTax;
        sellTax = _sellTax;
        transferTax = _transferTax;
        taxRecipient = _taxRecipient;
        treasuryAddress = _treasuryAddress;

        // Mint the initial supply to the caller
        _mint(msg.sender, initialSupply * 10 ** decimals());

        // Transfer ownership to the caller
        transferOwnership(msg.sender);
    }

    function setTaxRates(uint256 _buyTax, uint256 _sellTax, uint256 _transferTax) external onlyOwner {
        require(_buyTax <= 100 && _sellTax <= 100 && _transferTax <= 100, "Tax must be less than or equal to 100");
        buyTax = _buyTax;
        sellTax = _sellTax;
        transferTax = _transferTax;
    }


    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        uint256 taxAmount;
        if (sender == owner()) {
            // Exclude owner from buy tax
            taxAmount = (amount * buyTax) / 100;
        } else if (recipient == owner()) {
            // Exclude owner from sell tax
            taxAmount = (amount * sellTax) / 100;
        } else {
            taxAmount = (amount * transferTax) / 100;
        }
        uint256 treasuryTaxAmount = (amount * FIXED_TREASURY_TAX) / 1000;
        uint256 transferAmount = amount - taxAmount - treasuryTaxAmount;

        super._transfer(sender, taxRecipient, taxAmount);
        super._transfer(sender, treasuryAddress, treasuryTaxAmount);
        super._transfer(sender, recipient, transferAmount);
    }
}

// File: deployerlaunchpad.sol


pragma solidity ^0.8.0;


contract Launchpad {
    address public treasuryAddress;
    uint256 public tokenCount;

    struct TokenDetails {
        uint256 id;
        string name;
        string symbol;
        uint256 initialSupply;
        uint256 buyTax;
        uint256 sellTax;
        uint256 transferTax;
        address owner;
    }

    mapping(address => TokenDetails) public deployedTokens;
    mapping(uint256 => address) public tokenById;

    event TokenDeployed(
        address indexed tokenAddress,
        uint256 indexed id,
        address indexed owner,
        string name,
        string symbol,
        uint256 supply,
        uint256 buyTax,
        uint256 sellTax,
        uint256 transferTax
    );

    event TreasuryAddressChanged(address indexed oldAddress, address indexed newAddress);

    constructor(address _treasuryAddress) {
        treasuryAddress = _treasuryAddress;
        tokenCount = 0;
    }

    function deployMemeToken(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint256 buyTax,
        uint256 sellTax,
        uint256 transferTax,
        address taxRecipient,
        address newTreasuryAddress
    ) external returns (address) {
        TestMemeTaxedToken token = new TestMemeTaxedToken(name, symbol, initialSupply, buyTax, sellTax, transferTax, taxRecipient, newTreasuryAddress);

        token.transferOwnership(msg.sender);
        tokenCount++;
        deployedTokens[address(token)] = TokenDetails({
            id: tokenCount,
            name: name,
            symbol: symbol,
            initialSupply: initialSupply,
            buyTax: buyTax,
            sellTax: sellTax,
            transferTax: transferTax,
            owner: msg.sender
        });
        tokenById[tokenCount] = address(token);

        emit TokenDeployed(address(token), tokenCount, msg.sender, name, symbol, initialSupply, buyTax, sellTax, transferTax);
        return address(token);
    }

    function setTreasuryAddress(address newTreasuryAddress) external {
        require(newTreasuryAddress != address(0), "Treasury address cannot be the zero address");
        address oldAddress = treasuryAddress;
        treasuryAddress = newTreasuryAddress;
        emit TreasuryAddressChanged(oldAddress, newTreasuryAddress);
    }

    // View function to get token details by ID
    function getTokenDetailsById(uint256 id) external view returns (TokenDetails memory) {
        address tokenAddress = tokenById[id];
        require(tokenAddress != address(0), "Token does not exist.");
        return deployedTokens[tokenAddress];
    }

    // View function to get token details by address
    function getTokenDetailsByAddress(address tokenAddress) external view returns (TokenDetails memory) {
        require(deployedTokens[tokenAddress].owner != address(0), "Token does not exist.");
        return deployedTokens[tokenAddress];
    }
}
