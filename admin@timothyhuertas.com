<html>
	<head>
		<style>
			html, body, .game-container {
				height: 100%;
				margin: 0;
				padding: 0;
			}
			.tile {
				flex: 1;
				width: 1vh;
				height: 100%;
				box-sizing: border-box;
				border: 1px outset #ccc;
				display: inline-block;
				margin: auto;
				background: #bbb
			}

			.showing {
				border: 1px inset #ccc;
				background: #ddd;
			}

			.showing.bomb {
				background: #dd0000;
				border: 1px inset #bb0000;
			}

			.bsomb {
				background: red
			}

			.game-container {
				display: flex;
				flex-direction: column;
				width: 100vh;
				margin: auto
			}

			.row {
				flex: 1;
				height: 1vw;
				display: flex;
			}
		</style>

		<script type="text/javascript">
			class MindSweeper{
				initGame(element, numColumns, numRows, percentBombs, gameEndHandler){
					if(this.boundOnTileClick){
						this.element.removeEventListener("click", this.boundOnTileClick);
					}

					this.element = element;
					this.numColumns = numColumns;
					this.numRows = numRows;
					this.gameEndHandler = gameEndHandler;

					let numItems = numColumns*numRows;
					this.bombsToDrop = Math.round(percentBombs * numItems);
					this.tilesToFind = numItems - this.bombsToDrop;

					let matrix = this.createGameMatrx(numItems);
					this.graph = this.buildGraph(matrix, this.numColumns);
					this.render();

					this.boundOnTileClick = this.onTileClick.bind(this);
					this.element.addEventListener("click", this.boundOnTileClick);
				}

				createGameMatrx(numItems){
					let matrix = [];

					for(var i=0; i<numItems; i++){
						matrix.push(false);  
					}

					
					var bombsDropped= 0;

					while(this.bombsToDrop != bombsDropped){
						let bombIdx = Math.round(Math.random() * (numItems - 1));
						if(!matrix[bombIdx]){
							matrix[bombIdx] = true;
							bombsDropped++;
						}
					}

					return matrix;
				}

				endGame(msg){
					setTimeout(()=>{
						alert(msg);
						this.gameEndHandler();
					}, 1);
				}

				onTileClick(e) {
					if(e.target.classList.contains("tile")){
						let node = this.graph[parseInt(e.target.dataset.idx)];

						if(node.value){
							this.markAllAsShowing();
							this.endGame("loser")
						}
						else {
							this.sweep(node);
							if(this.tilesToFind == 0){
								this.markAllAsShowing();
								this.endGame("Winner winner chicken dinner!");
							}
						}

						this.render();
					}
				}

				markAllAsShowing(){
					this.graph.forEach((node) =>{
						node.showing = true;
					});
				}

				buildGraph(arr, itemsPerRow){
					return arr.reduce((nodes, value, idx) => {
						var node = this.nodeAtIndex(nodes, idx, arr);
						node.value = value;

						node.left = this.nodeAtIndex(nodes,idx - 1, arr);
						node.right = this.nodeAtIndex(nodes,idx + 1, arr);
						node.up = this.nodeAtIndex(nodes,idx - itemsPerRow, arr);
						node.down = this.nodeAtIndex(nodes,idx + itemsPerRow, arr);



						return nodes;
					}, [])
				}

				sweep(node){
					let queue = [];

					queue.push(node);

					while(queue.length){
						let node = queue.shift();

						if(!node.showing){
							node.showing = true;
							this.tilesToFind--;

							[node.left, node.right, node.up, node.down].forEach((n)=>{
								if(n && !n.value && !n.showing){
									queue.push(n);
								}
							});
						}
						
					}
				}

				nodeAtIndex(nodes, idx, game){
					if(idx >= 0 && idx < this.numRows * this.numColumns){
						var node = nodes[idx];

						if(!node){
							node = {};

							nodes[idx] = node;
						}

						return node;
					}
				}

				render(){
					let maxTileWidth = 100/this.numColumns + "%";
					var outer=0;
					var html = "";

					while(outer < this.graph.length){
						var inner = 0;
						html += `<div class="row">`; //start row

						while(inner<this.numColumns && outer+inner<this.graph.length){
							let curIdx = outer+inner;
							let item = this.graph[curIdx];

							var className = "tile ";
							if(item.showing){
								className += " showing";
							}
							else {
								className += " hidden";
							}

							if(item.value){
								className += " bomb";
							}

							html += `<div data-idx='${curIdx}' class='${className}'></div>`;
							
							inner++;
						}

						html += "</div>"; //end row

						outer += this.numColumns;
					}

					this.element.innerHTML = html;
				}
			}


			window.addEventListener("load", () => {
				let settings = {
					cols: 20,
					difficulty: .2
				}

				window.location.search.substr(1).split("&").reduce((settings, toupleStr)=>{
					let touple = toupleStr.split("=");
					settings[touple[0]] = new Number(touple[1]);

					return settings;
				}, settings);

				var mindSweeper = new MindSweeper();

				let start = () => {
					mindSweeper.initGame(document.querySelector(".game-container"), settings.cols, settings.cols, settings.difficulty, () => {
						start();
					});
				}

				start();
			});
			

			
			
		</script>
	</head>
	<body>
		<div class='game-container'>

		</div>
	</body>
</html>
