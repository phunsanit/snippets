import { Component, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { CommonModule } from '@angular/common';
import { TableModule } from 'primeng/table';
import { Observable } from 'rxjs';

interface Language {
  code: string;
  name: string;
}

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, TableModule],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App {
  private readonly http = inject(HttpClient);
  languages$: Observable<Language[]>;

  constructor() {
    this.languages$ = this.http.get<Language[]>('assets/iso-languages.json');
  }
}
