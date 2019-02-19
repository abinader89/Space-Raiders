import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { Stage, Layer, Image, Container, Rect } from 'react-konva';
import useImage from 'use-image';
import spaceShipImg from '../static/images/spaceship.svg';
import alienImage from '../static/images/enemy1.svg';

export default function game_init(root, channel) {
  console.log('game_init', root)
  ReactDOM.render(<Game channel={channel}/>, root);
}

const SpaceshipImage = (props) => {
  const [image] = useImage(spaceShipImg);
  return <Image {...{
    ...props,
    image: image,
    height: 50,
    width: 40,
  }}/>
}

const AlienImage = (props) => {
  const [image] = useImage(alienImage)
  return <Image {...{
    ...props,
    image: image,
    height: 50,
    width: 40,
    rotation: 180}}/>
}

class Game extends React.Component {
  constructor(props) {
    const { channel } = props;
    super(props);
    this.state = {
      aliens: [],
      barriers: [],
      players: [],
    };
    window.channel = channel
    this.onKeyDown = this.onKeyDown.bind(this)
    window.channel.join("space_raiders").receive("ok", () => {})
    //channel.on("ok", (game)=>this.setState(game))
    window.channel.on('new_tick', msg => {
      this.setState(msg)
    })
  }




  onKeyDown(e) {
    const { key } = e;
    if (key == "ArrowLeft" || key == "a") {
      window.channel.push("move", {id: 1, direction: "left"}).receive("ok", (game) => {this.setState(game.game);})
    } else if (e.key == "ArrowRight" || key == "d") {
      window.channel.push("move", {id: 1, direction: "right"}).receive("ok", (game) => {this.setState(game.game)})
    }
  }

  renderAliens(aliens){
    const out = [];
    aliens.forEach((alien) => {
      console.log(alien.posn.x, alien.posn.y)
      out.push(<AlienImage {...{x: (alien.posn.x * 10) + 40, y: alien.posn.y * 4}}/>);
    })
    return out;
  }


  renderBarriers(barriers){
    const out = [];
    barriers.forEach((barrier) => {
      out.push(<Rect {...{
        y: barrier.posn.y * 3,
        height: 20,
        width: 60,
        fill: 'black'}}/>)
    })
    return out;
  }

  renderPlayers(players) {
    const out = [];
    players.forEach((player) => {
      out.push(<SpaceshipImage {...{x: (player.posn.x) + 40, y: player.posn.y * 3}}/>)});
    return out
  }

  render() {
    const { players, aliens, barriers} = this.state;
    const alienComponents = this.renderAliens(aliens);
    const playerComponents = this.renderPlayers(players);
    const barrierComponents = this.renderBarriers(barriers);
    return <div tabIndex="0" onKeyDown={(e) => {console.log(e); this.onKeyDown(e)}}>
      <Stage width={750} height={1000}>
        <Layer>
          {playerComponents}
          {alienComponents}
          {barrierComponents}
        </Layer>
      </Stage>
    </div>
  }

}

