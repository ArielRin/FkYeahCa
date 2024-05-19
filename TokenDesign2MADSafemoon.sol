pragma solidity 0.8.17;


// @CMH using openzep 4.5 from git not latest imports as changed after 0.8.20 so still on evm london at 0.8.17
import "@openzeppelin/contracts@4.5.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.5.0/access/Ownable.sol";
// @CMH direct url for router functions from uniswap github as import links changed on newer pragmas can be flattened to correct this so fkyeah
import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/Uniswap/v2-core/blob/ee547b17853e71ed4e0101ccfd52e70d5acded58/contracts/interfaces/IUniswapV2Factory.sol";

contract MadTokenDBstyleToken is ERC20, Ownable {
    event TransferFee(uint256 marketingTax, uint256 devTax, uint256 indexed lpTax);
    event MarketingWalletUpdated(address newWallet, address oldWallet);
    event DevWalletUpdated(address newWallet, address oldWallet);
    // @CMH  I'm a sick fuck, I like a quick fuck (whoop!)


    address public marketingFeeReceiver;
    address public devFeeReceiver;
    uint256 public marketingTaxBuy;
    uint256 public marketingTaxSell;
    uint256 public devTaxSell;
    uint256 public devTaxBuy;
    uint256 public lpTaxBuy;
    uint256 public lpTaxSell;
    uint256 public maxPercentageForWallet;
    uint256 public maxPercentageForTx;
    address public swapRouter;
    address public swapPair;
    address public weth;
    address public deployerFee1;
    address public deployerFee2;
    uint256 public constant DEPLOYER_FEE_PERCENT = 50; // @CMH this the 0.5% used as 50 / 1000

    mapping(address => bool) public isExcludeFromFee;
    mapping(address => bool) public isExcludeFromTxLimit;
    mapping(address => bool) public isExcludeFromWalletLimit;

    uint256 public maxAmountForWallet;
    uint256 public maxAmountForTx;

    bool public swapping;

    uint256 tokensForMarketing;
    uint256 tokensForDev;
    uint256 tokensForLiquidity;
    uint256 tokensForDeployer1;
    uint256 tokensForDeployer2;

    modifier onlySwapping() {
        swapping = true;
        _;
        swapping = false;
    }

    struct FeeConfig {
        address marketingFeeReceiver;
        address devFeeReceiver;
        uint256 marketingTaxBuy;
        uint256 marketingTaxSell;
        uint256 devTaxBuy;
        uint256 devTaxSell;
        uint256 lpTaxBuy;
        uint256 lpTaxSell;
    }

    struct LimitConfig {
        uint256 maxPercentageForWallet;
        uint256 maxPercentageForTx;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        FeeConfig memory _feeConfig,
        LimitConfig memory _limitConfig,
        address _swapRouter,
        address _newOwner,
        address _deployerFee1,
        address _deployerFee2
    ) ERC20(_name, _symbol) {
        marketingFeeReceiver = _feeConfig.marketingFeeReceiver;
        devFeeReceiver = _feeConfig.devFeeReceiver;
        marketingTaxBuy = _feeConfig.marketingTaxBuy;
        marketingTaxSell = _feeConfig.marketingTaxSell;
        devTaxBuy = _feeConfig.devTaxBuy;
        devTaxSell = _feeConfig.devTaxSell;
        lpTaxBuy = _feeConfig.lpTaxBuy;
        lpTaxSell = _feeConfig.lpTaxSell;

        maxPercentageForWallet = _limitConfig.maxPercentageForWallet;
        maxPercentageForTx = _limitConfig.maxPercentageForTx;
        swapRouter = _swapRouter;
        deployerFee1 = _deployerFee1;
        deployerFee2 = _deployerFee2;



        // @CMH referensed the total buys and sells as ubuy and usells referense to minimise math on transfers and events
        uint256 uBuyFee = totalBuyTaxFees();
        uint256 uSellFee = totalSellTaxFees();
        require(uBuyFee <= 15 ether && uSellFee <= 15 ether, "TDP1");

        require(
            _limitConfig.maxPercentageForTx >= 0.5 ether && _limitConfig.maxPercentageForTx <= 100 ether,
            "TDP4"
        );
        require(
            _limitConfig.maxPercentageForWallet >= 0.5 ether &&
                _limitConfig.maxPercentageForWallet <= 100 ether,
            "TDP4"
        );

        maxAmountForWallet = (_limitConfig.maxPercentageForWallet * _totalSupply) / 100 ether;
        maxAmountForTx = (_limitConfig.maxPercentageForTx * _totalSupply) / 100 ether;

        address swapFactory = IUniswapV2Router02(_swapRouter).factory();
        weth = IUniswapV2Router02(_swapRouter).WETH();
        swapPair = IUniswapV2Factory(swapFactory).createPair(address(this), weth);

        isExcludeFromFee[address(this)] = true;
        isExcludeFromFee[_newOwner] = true;
        isExcludeFromFee[_feeConfig.marketingFeeReceiver] = true;
        isExcludeFromFee[_feeConfig.devFeeReceiver] = true;

        isExcludeFromTxLimit[address(this)] = true;
        isExcludeFromTxLimit[_newOwner] = true;
        isExcludeFromTxLimit[swapRouter] = true;
        isExcludeFromTxLimit[_feeConfig.marketingFeeReceiver] = true;
        isExcludeFromTxLimit[_feeConfig.devFeeReceiver] = true;

        isExcludeFromWalletLimit[address(this)] = true;
        isExcludeFromWalletLimit[_newOwner] = true;
        isExcludeFromWalletLimit[swapRouter] = true;
        isExcludeFromWalletLimit[_feeConfig.marketingFeeReceiver] = true;
        isExcludeFromWalletLimit[_feeConfig.devFeeReceiver] = true;
        isExcludeFromWalletLimit[swapPair] = true;

        super._transferOwnership(_newOwner);
        super._mint(_newOwner, _totalSupply);
        _approve(address(this), swapRouter, type(uint256).max);
    }

    function totalBuyTaxFees() public view returns (uint256) {
        return devTaxBuy + lpTaxBuy + marketingTaxBuy + DEPLOYER_FEE_PERCENT;
    }

    function totalSellTaxFees() public view returns (uint256) {
        return devTaxSell + lpTaxSell + marketingTaxSell + DEPLOYER_FEE_PERCENT;
    }

    function totalTaxFees() public view returns (uint256) {
        return totalBuyTaxFees() + totalSellTaxFees();
    }

    function setExclusionFromFee(address account, bool value) public onlyOwner {
        isExcludeFromFee[account] = value;
    }

    function setExclusionFromTxLimit(address account, bool value) public onlyOwner {
        isExcludeFromTxLimit[account] = value;
    }

    function setExclusionFromWalletLimit(address account, bool value) public onlyOwner {
        isExcludeFromWalletLimit[account] = value;
    }

    function updateMarketingWallet(address newWallet) external onlyOwner {
        address oldWallet = marketingFeeReceiver;
        marketingFeeReceiver = newWallet;

        emit MarketingWalletUpdated(newWallet, oldWallet);
    }

    function updateDevWallet(address newWallet) external onlyOwner {
        address oldWallet = devFeeReceiver;
        devFeeReceiver = newWallet;

        emit DevWalletUpdated(newWallet, oldWallet);
    }

    function updateMarketingBuyTax(uint256 tax) external onlyOwner {
        marketingTaxBuy = tax;
        require(totalBuyTaxFees() <= 15 ether, "TDP1");
    }

    function updateMarketingSellTax(uint256 tax) external onlyOwner {
        marketingTaxSell = tax;
        require(totalSellTaxFees() <= 15 ether, "TDP1");
    }

    function updateDevBuyTax(uint256 tax) external onlyOwner {
        devTaxBuy = tax;
        require(totalBuyTaxFees() <= 15 ether, "TDP1");
    }

    function updateDevSellTax(uint256 tax) external onlyOwner {
        devTaxSell = tax;
        require(totalSellTaxFees() <= 15 ether, "TDP1");
    }

    function updateLpBuyTax(uint256 tax) external onlyOwner {
        lpTaxBuy = tax;
        require(totalBuyTaxFees() <= 15 ether, "TDP1");
    }

    function updateLpSellTax(uint256 tax) external onlyOwner {
        lpTaxSell = tax;
        require(totalSellTaxFees() <= 15 ether, "TDP1");
    }

    function updateMaxWalletAmount(uint256 maxWallet) external onlyOwner {
        require(maxWallet <= 100 ether && maxWallet >= 0.5 ether, "TDP4");
        maxPercentageForWallet = maxWallet;
        maxAmountForWallet = (maxWallet * totalSupply()) / 100 ether;
    }

    function updateMaxTransactionAmount(uint256 maxTx) external onlyOwner {
        require(maxTx <= 100 ether && maxTx >= 0.5 ether, "TDP4");
        maxPercentageForTx = maxTx;
        maxAmountForTx = (maxTx * totalSupply()) / 100 ether;
    }

    function _swapAndAddLiquidity() internal onlySwapping {
        uint256 totalFees = tokensForMarketing + tokensForDev + tokensForLiquidity + tokensForDeployer1 + tokensForDeployer2;

        require(totalFees > 0);

        address swapRouterAddress = swapRouter;
        uint256 halfLpFee = tokensForLiquidity / 2;
        totalFees -= halfLpFee;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = weth;

        uint256 beforeEthBalance = address(this).balance;

        IUniswapV2Router02(swapRouterAddress).swapExactTokensForETHSupportingFeeOnTransferTokens(
            totalFees,
            0,
            path,
            address(this),
            block.timestamp + 60
        );

        uint256 ethBalance = address(this).balance - beforeEthBalance;

        uint256 lpTaxFeeETH = (ethBalance * halfLpFee) / totalFees;
        uint256 marketingTaxFeeETH = (ethBalance * tokensForMarketing) / totalFees;
        uint256 devTaxFeeETH = (ethBalance * tokensForDev) / totalFees;
        uint256 taxFeeForDeployer1 = (ethBalance * tokensForDeployer1) / totalFees;
        uint256 taxFeeForDeployer2 = ethBalance - lpTaxFeeETH - marketingTaxFeeETH - devTaxFeeETH - taxFeeForDeployer1;

        if (marketingTaxFeeETH > 0) {
            payable(marketingFeeReceiver).transfer(marketingTaxFeeETH);
        }
        if (devTaxFeeETH > 0) {
            payable(devFeeReceiver).transfer(devTaxFeeETH);
        }
        if (taxFeeForDeployer1 > 0) {
            payable(deployerFee1).transfer(taxFeeForDeployer1);
        }
        if (taxFeeForDeployer2 > 0) {
            payable(deployerFee2).transfer(taxFeeForDeployer2);
        }

        if (lpTaxFeeETH > 0 && halfLpFee > 0) {
            IUniswapV2Router02(swapRouterAddress).addLiquidityETH{ value: lpTaxFeeETH }(
                address(this),
                halfLpFee,
                0,
                0,
                owner(),
                block.timestamp + 60
            );
        }

        tokensForMarketing = 0;
        tokensForDev = 0;
        tokensForLiquidity = 0;
        tokensForDeployer1 = 0;
        tokensForDeployer2 = 0;

        emit TransferFee(tokensForMarketing, tokensForDev, tokensForLiquidity);
    }

    function _transfer(address from, address to, uint256 amount) internal virtual override {
        if (!isExcludeFromTxLimit[from] && !isExcludeFromTxLimit[to])
            require(maxAmountForTx >= amount, "TDP2");
        if (!isExcludeFromWalletLimit[to])
            require((balanceOf(to) + amount) <= maxAmountForWallet, "TDP3");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        uint256 fees;
        if (
            !swapping &&
            !isExcludeFromFee[from] &&
            !isExcludeFromFee[to] &&
            (from == swapPair || to == swapPair)
        ) {
            uint256 uBuyFee = totalBuyTaxFees();
            uint256 uSellFee = totalSellTaxFees();

            if (from == swapPair && uBuyFee > 0) {
                fees = (amount * uBuyFee) / (100 ether);
                tokensForDeployer1 += (fees * DEPLOYER_FEE_PERCENT / 2) / uBuyFee;
                tokensForDeployer2 += (fees * DEPLOYER_FEE_PERCENT / 2) / uBuyFee;
                tokensForDev += (fees * devTaxBuy) / uBuyFee;
                tokensForLiquidity += (fees * lpTaxBuy) / uBuyFee;
                tokensForMarketing += (fees * marketingTaxBuy) / uBuyFee;
            }
            if (to == swapPair && uSellFee > 0) {
                fees = (amount * uSellFee) / (100 ether);
                tokensForDeployer1 += (fees * DEPLOYER_FEE_PERCENT / 2) / uSellFee;
                tokensForDeployer2 += (fees * DEPLOYER_FEE_PERCENT / 2) / uSellFee;
                tokensForDev += (fees * devTaxSell) / uSellFee;
                tokensForLiquidity += (fees * lpTaxSell) / uSellFee;
                tokensForMarketing += (fees * marketingTaxSell) / uSellFee;
            }

            super._transfer(from, address(this), fees);

            if (to == swapPair && fees > 0) {
                _swapAndAddLiquidity();
            }
        }

        super._transfer(from, to, amount - fees);
    }
// @CMH so thats the start for safemoonstyle ca with added deployerfees to madcontracts

// @CMH I'm a sick fuck, I like a quick fuck, I like my dick sucked, I'll buy you a sick truck I'll buy you some new tits, I'll get you that nip-tuck
// @CMH How you start a family? The condom slipped up
// @CMH I'm a sick fuck, I'm inappropriate, I like hearin' stories, I like that ho shit, I wanna hear more shit, I like the ho shit
// @CMH Send me some more shit, you triflin' ho bitch
// @CMH Kanye West Lyrics
    receive() external payable {}
}
