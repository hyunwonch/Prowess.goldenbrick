import keyboard  # 실시간 키 입력 처리용
import time

class CycleNavigator:
    def __init__(self, filename):
        self.cycles = []
        self.index = 0
        self._load_cycles(filename)

    def _load_cycles(self, filename):
        with open(filename, 'r') as f:
            lines = f.readlines()

        current_cycle = []
        for line in lines:
            line = line.strip()
            if line.startswith("=== CYCLE"):
                if current_cycle:
                    self.cycles.append(current_cycle)
                    current_cycle = []
            elif line != "":
                current_cycle.append(line)
        if current_cycle:
            self.cycles.append(current_cycle)

    def show_current(self):
        print(f"\n--- CYCLE {self.index} ---")
        for line in self.cycles[self.index]:
            print(line)

    def next(self):
        if self.index < len(self.cycles) - 1:
            self.index += 1
            self.show_current()
        else:
            print("\n[Reached end of log]")

    def prev(self):
        if self.index > 0:
            self.index -= 1
            self.show_current()
        else:
            print("\n[At beginning of log]")

    def go_to(self, cycle_number):
        if 0 <= cycle_number < len(self.cycles):
            self.index = cycle_number
            self.show_current()
        else:
            print(f"\n[Invalid cycle number: {cycle_number}]")

    def total_cycles(self):
        return len(self.cycles)


def realtime_viewer(filename):
    nav = CycleNavigator(filename)
    print(f"\n[Simulation Log Loaded] Total Cycles: {nav.total_cycles()}")
    nav.show_current()

    print("\nPress → (right) for next, ← (left) for previous, 'q' to quit.\n")

    while True:
        if keyboard.is_pressed('right'):
            nav.next()
            time.sleep(0.2)  # 너무 빠르게 넘어가는 것 방지
        elif keyboard.is_pressed('left'):
            nav.prev()
            time.sleep(0.2)
        elif keyboard.is_pressed('q'):
            print("Exiting viewer.")
            break


if __name__ == "__main__":
    realtime_viewer("sim.txt")
