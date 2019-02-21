import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { Stage, Layer, Image, Container, Rect, Line } from 'react-konva';
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
      lasers: [],
      players: [],
      alien_lasers: []
    };
    window.channel = channel
    this.onKeyDown = this.onKeyDown.bind(this)
    //channel.on("ok", (game)=>this.setState(game))
    document.addEventListener("keydown", (event) => this.onKeyDown(event))
  }

  componentDidMount(){
    if(window.location.href.includes("/game/")) {
      window.channel.join("space_raiders").receive("ok", () => {}).receive("error", resp => console.log(resp))
      window.channel.on('new_tick', msg => {
      this.setState(msg)
      const { players } = msg
      players.forEach((player) => { if(player.name == window.userName) { window.id =  player.id }})
    })
      window.onunload = () => window.channel.push("disconnect", {id: window.id})
    }
  }



  renderPlayerLasers(lasers) {
    const out = [];
    const points = [0, 0, 0, -20]
    if(lasers[0]) console.log(lasers[0].posn.x, lasers[0].posn.y)
    lasers.forEach((laser) => {
      if(laser.inplay) {
        out.push(<Line {...{x: (laser.posn.x * 1.5), y: laser.posn.y * 3, points, stroke: "black"}}/>)
      }
    })
    return out;
  }

  renderAlienLasers(lasers){
    const out = [];
    const points = [0,0, 0,20]
    lasers.forEach((laser) => {
       out.push(<Line {...{x: (laser.x * 1.5), y: laser.y * 3, points, stroke: "red"}}/>)
    })
    return out;
  }

  onKeyDown(e) {
    const { key } = e;
    if (key == "e"){
          window.channel.push("fire", {id: window.id}).receive("ok", (game) => {this.setState(game.game);})
    } else if (key == "ArrowLeft" || key == "a") {
          window.channel.push("move", {id: window.id, direction: "left"}).receive("ok", (game) => {this.setState(game.game);})
    } else if (e.key == "ArrowRight" || key == "d") {
          window.channel.push("move", {id: window.id, direction: "right"}).receive("ok", (game) => {this.setState(game.game)})
    }
  }

  renderAliens(aliens){
    const out = [];
    aliens.forEach((alien) => {
      out.push(<AlienImage {...{x: (alien.posn.x *1.5), y: alien.posn.y * 3}}/>);
    })
    return out;
  }


  renderBarriers(barriers){
    const out = [];
    barriers.forEach((barrier) => {
      out.push(<Rect {...{
        y: barrier.posn.y * 3,
        x: (barrier.posn.x * 7) - 30,
        height: 20,
        width: 60,
        fill: 'black'}}/>)
    })
    return out;
  }

  renderPlayers(players) {
    const out = [];
    players.forEach((player) => {
      out.push(<SpaceshipImage {...{x: (player.posn.x*1.5) - 20, y: player.posn.y * 3}}/>)});
    return out
  }

  render() {
    const { players, aliens, barriers, lasers, alien_lasers} = this.state;
    const alienComponents = this.renderAliens(aliens);
    const playerComponents = this.renderPlayers(players);
    const barrierComponents = this.renderBarriers(barriers);
    const laserComponents = this.renderPlayerLasers(lasers);
    console.log(aliens.map(alien => alien.posn))
    const alienLaserComponents = this.renderAlienLasers(alien_lasers);
    return <div tabIndex="0">
      <Stage width={900} height={1000}>
        <Layer>
          {playerComponents}
          {alienComponents}
          {barrierComponents}
          {laserComponents}
          {alienLaserComponents}
        </Layer>
      </Stage>
    </div>
  }

}

